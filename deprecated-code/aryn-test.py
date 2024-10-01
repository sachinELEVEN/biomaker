import aryn_sdk
import sys
from aryn_sdk.partition import partition_file, tables_to_pandas
import pandas as pd
from io import BytesIO
import json
import re

def localprint(*data, doPrint=False):
    if doPrint:
        print(*data)
 

#Providing file path from nodejs
# Get file paths from command-line arguments
file_path = sys.argv[1] if len(sys.argv) > 1 else None
# You can add more file paths if needed (e.g., sys.argv[2], sys.argv[3], etc.)

if file_path is None:
    localprint("No file path provided.")
    sys.exit(1)

# file = open(file_path, 'rb')
# aryn_api_key = 'your_api_key_here'  # Use your actual API key

file_full = '/Users/sachinjeph/Desktop/biomarker/repo/assets/Sachin_M_23_2024_2 copy.pdf'
file_single = '/Users/sachinjeph/Desktop/biomarker/repo/assets/single-page-medical-report-img.pdf'
file_single2 = '/Users/sachinjeph/Desktop/biomarker/repo/assets/sample-report-3.pdf'
file_single3 = '/Users/sachinjeph/Desktop/biomarker/repo/assets/sample-report4.pdf'
file = open(file_path, 'rb')
aryn_api_key = 'eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJzdWIiOnsiZW1sIjoia3VtYXJqYWdkZXNoODExQGdtYWlsLmNvbSIsImFjdCI6IjQzMDcyODg2MjQyNCJ9LCJpYXQiOjE3Mjc1MjU1MjMuMTA2NzU0M30.JYhkly2EZ2YNtyS9sH64R8tFsQrDdW14RpMyNOXkK5BW6l37nyXsyxW-r8l2AfTvoKZEw5IZxRdl997xgJnGCA'

## Make a call to the Aryn Partitioning Service (APS) 
## param extract_table_structure (boolean): extract tables and their structural content. default: False
## param use_ocr (boolean): extract text using an OCR model instead of extracting embedded text in PDF. default: False
## returns: JSON object with elements representing information inside the PDF
partitioned_file = partition_file(file, aryn_api_key, extract_table_structure=True, use_ocr=True)
localprint("******************ORIGINAL RESPONSE")
localprint(partitioned_file)
localprint("******************ORIGINAL RESPONSE ABOVE")

# pandas = tables_to_pandas(partitioned_file)



# tables = []
# #pull out the tables from the list of elements
# for elt, dataframe in pandas:
#     if elt['type'] == 'table':
#         tables.append(dataframe)
        
# # supplemental_income = tables[0]
# for table in tables:
#     localprint("#####")
#     localprint(table)#maybe later we just send this data to gpt for better analysis as out input token will be very less, using gpt should be cheap enough i think
# display(supplemental_income)
# localprint(supplemental_income)

def parse_tables(json_data):

    if len(json_data) == 0:
        localprint("The dictionary is empty.")
        return{}
   

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

# Create a table from the response json
result = parse_tables(partitioned_file)

#validate header row- should contain header information which denotes a medical test table
def validate_and_header_row(parsed_table, a, b, c, d):

    if len(parsed_table) == 0:
        localprint("The dictionary is empty.")
        return{}

    # Initialize an empty dictionary to store valid tables
    valid_tables = {}

     # Convert substrings to lowercase for case-insensitive comparison
    a_lower = a.lower()
    b_lower = b.lower()
    c_lower = c.lower()
    d_lower = d.lower()

    # Iterate over each table in the parsed_table
    for table_key, rows in parsed_table.items():
        # Get the first row (row 0) column names
        first_row = rows.get(0, {})

        # Extract column names from the first row
        column_names = list(first_row.values())

        # Check if there are at least 3 columns
        if len(column_names) < 3:
            localprint(f"Invalid table found (not enough columns): {table_key}")
            continue
        # Check if at least one column contains substring 'a', 'b', and 'c' (case insensitive)
        has_a = any(a_lower in col_name.lower() for col_name in column_names)
        has_b = any(b_lower in col_name.lower() for col_name in column_names)
        has_c = any(c_lower in col_name.lower() for col_name in column_names)

        # Check for any column names that do not contain a, b, c, or d
        localprint("validate_and_header_row Header columns-",column_names)
        invalid_column_found = any(
            not any(substring in col_name.lower() for substring in (a_lower, b_lower, c_lower, d_lower))
            for col_name in column_names
        )
        #For now now if extra column is there it is fine
        invalid_column_found = False

        localprint("validate_and_header_row: conditions for validity:",has_a,has_b,has_c,invalid_column_found)
        if not (has_a and has_b and has_c) or invalid_column_found:
            localprint(f"Invalid table found: {table_key}")
            continue

        # If valid, store the valid table
        valid_tables[table_key] = rows

    return valid_tables

#  Verify if the table has valid headers
#these are something - user may need to change based on his/her report title
test_name_header = 'test'
test_value_header = 'value'
test_unit_header = 'unit'
test_ref_header = 'ref'
valid_header_table = validate_and_header_row(result,test_name_header,test_value_header,test_unit_header,test_ref_header)

localprint("valid_header_table",valid_header_table)

#Merge columns having the same header name
def combine_duplicate_columns(parsed_table):

    if len(parsed_table) == 0:
        localprint("The dictionary is empty.")
        return{}

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
        duplicates = {col_name: count for col_name, count in column_count.items() if count >= 1}

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
                        new_col_name = f"combined-{col_name}"#denotes a combined column
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
                    new_row[new_col_name].append(value)
                
                # Concatenate the values for duplicate columns
                for col_name in duplicates.keys():
                    if col_name in new_row:
                        new_row[new_column_map[col_name]] = ' '.join(new_row[new_column_map[col_name]])
                        del new_row[new_column_map[col_name]]
                
                new_rows[row_index] = new_row
            
            combined_tables[table_key] = new_rows
    
    return combined_tables

#combine_duplicate_columns also modified subsequent rows where each new row is other than 1 is completely self explaining.
#each non-zero row has the test_name_header and its value, test_unit_header and its value, test_value_header and its value, and optionally test_ref_header and its value  and similarly for other headers 
merged_cols_table = combine_duplicate_columns(valid_header_table)
localprint("merged_cols_table",merged_cols_table)

#Normalization of column names

def is_number(var):
    try:
        float(var)  # Try to convert to float
        return True
    except ValueError:
        return False
    
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

#Flattens the dictionary in only 2 levels - level1 - table name. level 2 is a test,value, plottable etc and tells if its plottable or not depending on if the value is of type number or not
    #Sample output of this method:
        # {
        #   "table_1": [
        #     {
        #       "test": "ERYTHROCYTE SEDIMENTATION RATE (ESR)",
        #       "TECHNOLOGY": "MODIFIED WESTERGREN",
        #       "plottable": "yes",
        #       "value": "15",
        #       "unit": "mm 1hr"
        #     },
        #     {
        #       "test": "Bio. Ref. Interval.Bio. Ref. Interval.",
        #       "TECHNOLOGY": "Bio. Ref. Interval.",
        #       "plottable": "no",
        #       "value": "Bio. Ref. Interval.",
        #       "unit": "Bio. Ref. Interval."
        #     },
        #     {
        #       "test": "Male 0-15Male 0-15",
        #       "TECHNOLOGY": "Male 0-15",
        #       "plottable": "no",
        #       "value": "Male 0-15",
        #       "unit": "Male 0-15"
        #     },
        #     {
        #       "test": "Female 0-20Female 0-20",
        #       "TECHNOLOGY": "Female 0-20",
        #       "plottable": "no",
        #       "value": "Female 0-20",
        #       "unit": "Female 0-20"
        #     },
        #     {
        #       "test": "Please correlate with clinical conditions:Please correlate with clinical conditions:",
        #       "TECHNOLOGY": "Please correlate with clinical conditions:",
        #       "plottable": "no",
        #       "value": "Please correlate with clinical conditions:",
        #       "unit": "Please correlate with clinical conditions:"
        #     },
        #     {
        #       "test": "Method:-MODIFIED WESTERGREN",
        #       "TECHNOLOGY": "",
        #       "plottable": "no",
        #       "value": "",
        #       "unit": ""
        #     }
        #   ]
        # }
def flatten_dict_standardize_col_names(data, *tuples):

    if len(data) == 0:
            localprint("The dictionary is empty.")
            return{}


    updated_data = {}

    # Iterate over the main dictionary
    for outer_key, inner_dict in data.items():
        updated_inner_list = []
        ignored_header_row = False
        # Iterate over each inner dictionary
        for keyLevel2, valueLevel2 in inner_dict.items():
            updated_inner_level_3_list = {}
            for keyLevel3, valueInnerLevel3 in valueLevel2.items():

                # Check each tuple to see if we need to rename the key to use standard key names
                new_key_level3 = str(keyLevel3)
                for old_substring, new_key_value in tuples:
                    if old_substring in new_key_level3.lower():  # Case insensitive
                        new_key_level3 = new_key_value  # Replace the entire key with new_key_value
                    
                    #if new_key_level3 == value, we need to check if its value is can be plotted or not aka if its a number or not
                    valueInnerLevel3 = ''.join(valueInnerLevel3) if isinstance(valueInnerLevel3, list) else valueInnerLevel3

                    if new_key_level3 == 'value':
                        isNumber = is_number(valueInnerLevel3)
                        if isNumber:
                            updated_inner_level_3_list['plottable'] = "yes"
                        else:
                            updated_inner_level_3_list['plottable'] = "no"

                    #see if we have ref values, then we need to find upper and lower limit of reference
                    if new_key_level3 == 'ref':
                        isNumber = is_number(valueInnerLevel3)
                        ref_values =extract_numbers(valueInnerLevel3)
                        if ref_values[0] == -1 and ref_values[1] == -1:
                            updated_inner_level_3_list['plottableref'] = "no"
                        else:
                            updated_inner_level_3_list['plottableref'] = "yes"
                            updated_inner_level_3_list['plottablereflowerlimit'] = f"{ref_values[0]}"
                            updated_inner_level_3_list['plottablerefupperlimit'] =f"{ref_values[1]}"

                updated_inner_level_3_list[new_key_level3] = valueInnerLevel3
            
            if ignored_header_row:
                #we will not need the header row which is the first row
                updated_inner_list.append(updated_inner_level_3_list)
            else:
                ignored_header_row = True
         
        updated_data[outer_key] = updated_inner_list

    return updated_data





test_name_header_normalized = 'test'
test_value_header_normalized = 'value'
test_unit_header_normalized = 'unit'
test_ref_header_normalized = 'ref'

tuple1 = (test_name_header,test_name_header_normalized)
tuple2 = (test_value_header,test_value_header_normalized)
tuple3 = (test_unit_header,test_unit_header_normalized)
tuple4 = (test_ref_header,test_ref_header_normalized)

normalized_column_names_table = flatten_dict_standardize_col_names(merged_cols_table,tuple1,tuple2,tuple3,tuple4)


localprint(json.dumps(normalized_column_names_table, indent=2),doPrint=True)

# sys.stdout.flush()
#Now we need to parse this this data so that we only have what we want
# columnsNamesOfInterest = ['*test*','*ref*','*unit*','*value*']

#Now we want to remove useless data from the table
#Now create another function which takes the input of the parse_table method and performs the below functions, note it takes in 4 arguments-a,b,c,d which are strings.
#1. checks if the row 0 columns are valid or not. Row 0's columns are valid if and only if the columns name satisfy the below criterias-
    #1.1 any of the column name contains substring 'a'
    #1.3 any of the column name contains substring 'b'
    #1.3 any of the column name contains the substring  'c'
    #1.4 if the column name exists such that it does not contain any of the substring a or b or c or d. then return from the function with [] dictionary and log invalid table

