from img2table.document import PDF
from img2table.ocr import TesseractOCR
import os
import pandas as pd



pdf_path = "assets/single-page-medical-report-img.pdf"  # Path to your input PDF
output_folder = "output_tables"         # Folder to save the extracted tables as CSV
os.makedirs(output_folder, exist_ok=True)

# Initialize Tesseract OCR engine (ensure tesseract is installed)
ocr = TesseractOCR(lang="eng")  # "eng" is for English. You can specify other languages if needed.

# Load the PDF document
pdf_document = PDF(pdf_path)

# Extract tables from the PDF using the OCR engine
# The output will be a dictionary containing tables for each page
extracted_tables = pdf_document.extract_tables(ocr=ocr,borderless_tables=True)

print("Extracting tables-",extracted_tables)
# print("Extracting tables-",extracted_tables[2])
# print("Extracting tables-",extracted_tables[3])
# print("Extracting tables-",extracted_tables[4])
# print("Extracting tables-",extracted_tables[5])
# print("Extracting tables-",extracted_tables[6])
# print("Extracting tables-",extracted_tables[7])



# Loop through each page's tables and save them
# for page_num, tables in extracted_tables.items():
#     for idx, table in enumerate(tables):
#         output_file = f"{output_folder}/page_{page_num}_table_{idx + 1}.xlsx"
#         table._to_worksheet(output_file)  # Save the table as CSV
#         # print(table._to_worksheet())
#         print(f"Table saved to: {output_file}")


#  Save each extracted table to a CSV
# for i, table in enumerate(extracted_tables):
#     df = pd.DataFrame(table)  # Convert to DataFrame
#     df.to_csv(f'table_{i}.csv', index=False)  # Save to CSV
# for table in extracted_tables:
#     for id_row, row in enumerate(table.content.values()):
#         for id_col, cell in enumerate(row):
#             x1 = cell.bbox.x1
#             y1 = cell.bbox.y1
#             x2 = cell.bbox.x2
#             y2 = cell.bbox.y2
#             value = cell.value
#             print(x1,y1,x2,y2,value)