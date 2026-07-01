import argparse
import os
import re

def process_file(file_path, license_header):
    """Process a single file.

    If the file already has a license header, the file is skipped.
    Otherwise, the license header is prepended to the beginning of the file.

    Args:
        file_path: The path to the file.
        license_header: The license header to be added to the file.
    """
    # Read the file contents into a string
    with open(file_path, 'r') as f:
        file_contents = f.read()

    # Use a regular expression to check for the presence of a license header
    if re.match(r'^Copyright \d{4} .*', file_contents):
        print(f'Skipping {file_path}: license header already present')
        return

    # Prepend the license header to the beginning of the file contents
    modified_contents = license_header + file_contents

    # Write the modified contents back to the file
    with open(file_path, 'w') as f:
        f.write(modified_contents)

def main():
    """Add a license header to all the files in a given directory.

    The directory and license template file are specified as command line arguments.

    Usage:
        python add_license_header.py [directory] --template [template_file]
    """
    # Parse the directory path and template file path from the command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', help='the directory to search for files in')
    parser.add_argument('--template', help='the path to the license template file')
    args = parser.parse_args()
    directory = args.directory
    template_path = args.template

    # Check if the directory exists
    if not os.path.exists(directory):
        print(f'Error: directory {directory} does not exist')
        return

    # Check if the template file exists
    if not os.path.exists(template_path):
        print(f'Error: template file {template_path} does not exist')
        return

    # Read the contents of the template file
    with open(template_path, 'r') as f:
        license_header = f.read()

    # Search for files recursively in the given directory
    for dirpath, _, filenames in os.walk(directory):
        for filename in filenames:
            file_path = os.path.join(dirpath, filename)
            process_file(file_path, license_header)

if __name__ == '__main__':
    main()
