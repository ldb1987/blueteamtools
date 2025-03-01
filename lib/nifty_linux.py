import json
import nftables

def get_rules(rules: dict) -> str:
    return json.dump(rules)

#Save current rules to JSON file
def save_rules(filename: str, rules: dict) -> str:
    rules_file = open(filename, mode="w")
    rules_string = json.dumps(rules)
    rules_file.write(rules_string)
    return

#Load from json file. Not intended to be called directly
def load_file(filename: str):
    table_file = open(filename, mode="r")
    table_file = json.load(table_file)
    return table_file

#Load list of tables from file
def load_tables(filename: str) ->list[dict]:
    return load_file(filename)

#Load individual table from file
def load_table(filename: str) ->dict:
    return load_file(filename)

#Load individual chain from file
def load_chain(filename: str) ->dict:
    return load_file(filename)

#Load list of rules from file
def load_rules(filename: str) ->list[dict]:
    return load_file(filename)

#Create chains that do not exist
def parse_tables(tables_list: list[dict], family="inet") -> list:
    nftables_list = {"nftables":[]}
    for table in tables_list:
        name = table["name"]
        nftables_list["nftables"].append(
                {"add":{"table":{
                    "family":family,
                    "name":name
                }}}
            )
        nftables_list["nftables"].extend(parse_chains(table))
        for chain in table["chains"]:
            nftables_list["nftables"].extend(parse_rules(chain, name))
    
    return nftables_list

def parse_chains(table: dict, family="inet") -> list:
    chain_rules = []
    chains_list = table["chains"]
    table_name = table["name"]
    for chain in chains_list:
        chain_name = chain["name"]
        chain_rules.append(
                {"add":{"chain":{
                    "family":family,
                    "table":table_name,
                    "name":chain_name
                }}}  
            )
        
        
    return chain_rules

def parse_rules(chain: dict, table_name: str, family="inet") -> list:
    rules_list = []
    rules = chain["rules"]
    chain_name = chain["name"]

    for rule in rules:
        rules_list.append(
            {"add": {"rule": {
                    "family": family,
                    "table": table_name,
                    "chain": chain_name,
                    "expr": make_rule(rule)
            }}}
        )
    return rules_list


def make_rule(rule: dict) -> list:
    expr = []
    new_rule = {"match":{"op":{"=="},
                         "left":{"payload":{}
                                }}}
    if src := rule["src"]:
        src_match = {
                        "op":"==",
                        "left":{"payload":{
                            "protocol":"ip",
                            "field":"saddr"
                        }},
                        "right":src
                    }
        expr.append({"match":src_match})
    if dst := rule["dst"]:
        dst_match = {
                        "op":"==",
                        "left":{"payload":{
                            "protocol":"ip",
                            "field":"daddr"
                        }},
                        "right":dst
        }
        expr.append({"match":dst_match})
    if protocol := rule["protocol"]:
        protocol_match = {
                            "op": "==",
                            "left": {"payload":{
                                "protocol":protocol
                            }}
        }
        if sport := rule["sport"]:
            sport_match = protocol_match
            sport_match["left"]["payload"].update({
                "field":"sport"
            })
            sport_match.update({"right":sport})
            expr.append({"match":sport_match})
        if dport := rule["dport"]:
            dport_match = protocol_match
            dport_match["left"]["payload"].update({
                "field":"dport"
            })
            dport_match.update({"right":dport})
            expr.append({"match":dport_match})
    if in_interface := rule["ifin"]:
        iif_match = {
            "op":"==",
            "left": {
                "meta":{
                    "key":"iifname"
                }
            },
            "right":in_interface
        }
        expr.append({"match":iif_match})
    if out_interface := rule["ifout"]:
        oif_match = {
            "op":"==",
            "left": {
                "meta":{
                    "key":"oifname"
                }
            },
            "right":out_interface
        }
        expr.append({"match":oif_match})
    expr.append({rule["target"]:None})

    return expr

def init_table():
    return nftables.Nftables()

def write_rules(rules, table:nftables.Nftables):

    
    fuckyou = json.dumps(rules)
    open("nftables_out.json", mode="w").write(fuckyou)

    if table.json_validate(rules):
        table.json_cmd(rules)