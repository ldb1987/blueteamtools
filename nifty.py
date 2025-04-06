#!/bin/python3

from lib.nifty_linux import *
import sys
import os

def set_table(name: str):
    pass
    

def main():
    
    args = sys.argv

    if len(args) < 2:
        print("Must provide at least path of rules file")
        return
    
    filename = args[-1]

    if not os.path.exists(filename):
        print(f"Error: path {filename} does not exist")
        return

    #-t will set table type
    while len(args) > 2:
        match args[1].lower():
            case "-t":
                table = set_table(args[2])
                del args[:2]
                continue
    
    

    tables = load_tables(filename)

    tables = parse_tables(tables)

    nft = nftables.Nftables()

    if nft.json_validate(tables):
        print(json.dumps(tables))
        nft.json_cmd(tables)

if __name__=="__main__":
    main()