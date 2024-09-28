import json

def parse_tables(json_data):
    # Initialize a dictionary to hold the parsed tables
    parsed_tables = {}

    # Iterate through each element in the 'elements' list
    for element in json_data.get("elements", []):
        # Check if the element is of type 'table'
        if element.get("type") == "table":
            # Get the table's details
            table_data = element.get("table", {})
            cells = table_data.get("cells", [])

            # Prepare to structure the table in a dictionary format
            rows_dict = {}
            for cell in cells:
                content = cell.get("content")
                row_indices = cell.get("rows", [])
                col_indices = cell.get("cols", [])

                # Iterate through row indices to populate the rows_dict
                for row in row_indices:
                    # If the row is not in the dictionary, initialize it
                    if row not in rows_dict:
                        rows_dict[row] = {}

                    # Assign cell content to the correct column in the row
                    for col in col_indices:
                        rows_dict[row][col] = content

            # Add the constructed table to the parsed_tables dictionary
            parsed_tables[f'table_{len(parsed_tables) + 1}'] = rows_dict

    return parsed_tables

# Example usage
json_response = {
    "status": [
        # Your status messages here...
    ],
    "elements": [
        {
            "type": "Caption",
            # Other properties...
        },
        {
            "type": "table",
            "table": {
                "cells": [
                    {
                        "content": "TEST NAME",
                        "rows": [0],
                        "cols": [0, 1],
                    },
                    {
                        "content": "TECHNOLOGY",
                        "rows": [0],
                        "cols": [2],
                    },
                    {
                        "content": "VALUE",
                        "rows": [0],
                        "cols": [3],
                    },
                    {
                        "content": "UNITS",
                        "rows": [0],
                        "cols": [4],
                    },
                    {
                        "content": "",
                        "rows": [1],
                        "cols": [0],
                    },
                    {
                        "content": "ERYTHROCYTE SEDIMENTATION RATE (ESR)",
                        "rows": [1],
                        "cols": [1],
                    },
                    {
                        "content": "MODIFIED WESTERGREN",
                        "rows": [1],
                        "cols": [2],
                    },
                    {
                        "content": "15",
                        "rows": [1],
                        "cols": [3],
                    },
                    {
                        "content": "mm 1hr",
                        "rows": [1],
                        "cols": [4],
                    },
                    # Other cells...
                ],
            },
        },
    ],
}

# Calling the function
result = parse_tables(json_response)

# Print the result
print(json.dumps(result, indent=2))

def combine_duplicate_columns(parsed_table):
    combined_tables = {}

    for table_key, rows in parsed_table.items():
        # Get the first row (row 0) values
        first_row = rows.get(0, {})
        
        # Get column names and count occurrences
        column_names = list(first_row.values())
        column_count = {}
        
        for col_name in column_names:
            column_count[col_name] = column_count.get(col_name, 0) + 1

        # Identify duplicate columns
        duplicates = {col_name: count for col_name, count in column_count.items() if count > 1}

        if duplicates:
            # Create a new dictionary to store the combined table
            new_rows = {}
            new_column_map = {}

            # Combine duplicate columns for row 0
            new_row_0 = {}
            new_index = 0
            
            for index, col_name in enumerate(column_names):
                if col_name in duplicates:
                    if col_name not in new_column_map:
                        new_col_name = f"combined-{col_name}"
                        new_row_0[new_index] = new_col_name
                        new_column_map[col_name] = new_col_name
                        new_index += 1
                else:
                    new_row_0[new_index] = col_name
                    new_column_map[col_name] = col_name
                    new_index += 1
            
            new_rows[0] = new_row_0
            
            # Combine values for other rows based on the new column mapping
            for row_index, row in rows.items():
                if row_index == 0:
                    continue
                
                new_row = {}
                for original_col_name, value in row.items():
                    new_col_name = new_column_map[column_names[original_col_name]]
                    if new_col_name not in new_row:
                        new_row[new_col_name] = []
                    # print("H->",new_row[new_col_name],new_col_name)
                    new_row[new_col_name].append(value)
                    # new_row[new_col_name].append(value)
                
                # Concatenate the values for duplicate columns
                for col_name in duplicates.keys():
                    if col_name in new_row:
                        new_row[new_column_map[col_name]] = ' '.join(new_row[new_column_map[col_name]])
                        del new_row[new_column_map[col_name]]
                
                new_rows[row_index] = new_row
            
            combined_tables[table_key] = new_rows

    return combined_tables

# Example usage
filtered_result = {
    "table_1": {
        0: {0: "TEST NAME", 1: "TECHNOLOGY", 2: "TECHNOLOGY", 3: "VALUE", 4: "UNITS"},
        1: {0: "Test A", 1: "Tech 1", 2: "Tech 2", 3: "15", 4: "mm 1hr"},
        2: {0: "Test B", 1: "Tech 3", 2: "Tech 4", 3: "20", 4: "mm 2hr"},
        # Other rows...
    }
}

# Call the function
combined_result = combine_duplicate_columns(filtered_result)

# Print the result
print(json.dumps(combined_result, indent=2))

def flatten_dict(data, *tuples):
    updated_data = {}

    # Iterate over the main dictionary
    for outer_key, inner_dict in data.items():
        updated_inner_list = []

        # Iterate over each inner dictionary
        for keyLevel2, valueLevel2 in inner_dict.items():
            updated_inner_level_3_list = {}
            for keyLevel3, valueInnerLevel3 in valueLevel2.items():

                # Check each tuple to see if we need to rename the key to use standard key names
                new_key_level3 = str(keyLevel3)
                for old_substring, new_key_value in tuples:
                    if old_substring in new_key_level3.lower():  # Case insensitive
                        new_key_level3 = new_key_value  # Replace the entire key with new_key_value
            
                updated_inner_level_3_list[new_key_level3] =''.join(valueInnerLevel3) if isinstance(valueInnerLevel3, list) else valueInnerLevel3
            updated_inner_list.append(updated_inner_level_3_list)
         
        updated_data[outer_key] = updated_inner_list

    return updated_data



# Sample input dictionary
input_data = {
    "table_1": {
        0: {
            0: "combined-TEST NAME",
            "1": "TECHNOLOGY",
            "2": "VALUE",
            "3": "UNITS"
        },
        "1": {
            "combined-TEST NAME": [
                "",
                "ERYTHROCYTE SEDIMENTATION RATE (ESR)"
            ],
            "TECHNOLOGY": [
                "MODIFIED WESTERGREN"
            ],
            "VALUE": [
                "15"
            ],
            "UNITS": [
                "mm 1hr"
            ]
        }
    }
}

# Example Usage:
# Replace keys containing 'combined' with 'TEST NAME' and 'TECH' with 'TECHNOLOGY'
new_data = flatten_dict(input_data, ("combined", "TEST NAME2"), ("tech", "TECHNOLOGY2"))

# Print the modified dictionary
# print(new_data)
print("##################")
print(json.dumps(new_data, indent=2))


import re

def extract_numbers(input_string):
    # Check for ':' delimiter first
    if ':' in input_string:
        # Split the input string into parts by space, comma, or hyphen
        parts = re.split(r'[\s, -]+', input_string)
        numbers = []
        
        for part in parts:
            if ':' in part:  # If part contains ':', split it
                try:
                    num1, num2 = map(float, part.split(':'))
                    if num2 != 0:  # Avoid division by zero
                        numbers.append(num1 / num2)
                except (ValueError, ZeroDivisionError):
                    continue  # Ignore non-numeric values or incorrect splits
            
            # If not a part with ':', check for standalone numbers
            else:
                try:
                    num = float(part)
                    numbers.append(num)
                except ValueError:
                    continue  # Ignore non-numeric values

        # Return the first two numbers if found
        if len(numbers) >= 2:
            return numbers[:2]

    # Otherwise, look for numbers separated by space, comma, or hyphen
    matches = re.split(r'[\s, -]+', input_string)  # Split by spaces, commas, or hyphens
    
    # Filter out any empty strings and non-numeric values, converting to float
    valid_numbers = []
    for num in matches:
        try:
            valid_numbers.append(float(num))
        except ValueError:
            continue  # Ignore non-numeric values

    # Check if we found any valid numbers
    if not valid_numbers:
        return [-1, -1]

    # Check if we found exactly two numbers
    if len(valid_numbers) >= 2:
        return valid_numbers[:2]

    return [-1, -1]

# Example usage:
print(extract_numbers("12.5, 3.4"))         # Output: [12.5, 3.4]
print(extract_numbers("42 - 23"))            # Output: [42.0, 23.0]
print(extract_numbers("0.72-2.1"))           # Output: [0.72, 2.1]
print(extract_numbers("9:2-15:3"))           # Output: [4.5, 5.0]
print(extract_numbers("No numbers here"))    # Output: [-1, -1]
print(extract_numbers("5.5 7"))              # Output: [5.5, 7.0]
print(extract_numbers("Hello 5"))            # Output: [-1, -1]
