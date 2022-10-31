#!/usr/bin/python3

import os
import subprocess
import sys

def confirm(prompt):
    while True:
        print(prompt, end=' (y/n): ')
        sys.stdout.flush()
        if input().strip().lower() in ['y', 'yes']:
            return True
        elif input().strip().lower() in ['n', 'no']:
            return False
        else:
            print("Please answer 'y' or 'n'")

def main(args):
    empty_subdirs = list_empty_subdirs(args.path, count_hidden_files=args.keep_hidden_files)[1]
    if args.dry_run:
        print(*empty_subdirs, sep='\n')
    else:
        subprocesses = []
        for empty_subdir in empty_subdirs:
            if (not args.confirm) or confirm(empty_subdir):
                subprocess.Popen(['rm', '-r', empty_subdir])
        for proc in subprocesses:
            proc.wait()
    return 0

def usage():
    print("Usage: clean-empty-dirs.py [--dry-run] <path>")

def list_empty_subdirs(root, count_hidden_files=False):
    """Outputs a tuple of (entirely empty?, [empty subdirs])
    
    The list does not contain nested directories (e.g. if foo and foo/bar
    are empty, it only contains foo).
    """
    entries = [f for f in os.scandir(root)]
    files = [f for f in entries if f.is_file() and (count_hidden_files or not f.name.startswith("."))]
    subdirs = [f for f in entries if f.is_dir() and (count_hidden_files or not f.name.startswith("."))]
    empty_subdirs = []
    all_subdirs_empty = True
    for subdir in subdirs:
        is_subdir_empty, empty_subsubdirs = list_empty_subdirs(subdir, count_hidden_files=count_hidden_files)
        all_subdirs_empty = all_subdirs_empty and is_subdir_empty
        empty_subdirs += empty_subsubdirs
    if files or not all_subdirs_empty:
        return (False, empty_subdirs)
    else:
        if type(root) is str:
            return (True, [root])
        else:
            return (True, [root.path])

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(
        prog = 'clean-empty-dirs.py',
        description = 'Remove or list empty directories'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='List empty directories instead of removing them',
    )
    parser.add_argument(
        '--keep-hidden-files',
        action='store_true',
        help='Keep hidden files and directories instead of skipping over them',
    )
    parser.add_argument(
        '-c', '--confirm',
        action='store_true',
        help='Confirm before removing a directory',
    )
    parser.add_argument(
        'path',
        help='The path from which to begin looking for empty directories',
    )
    args = parser.parse_args()
    exit(main(args))
