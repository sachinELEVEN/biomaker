# new in v0.3: gmft.auto
from gmft.auto import CroppedTable, TableDetector, AutoTableFormatter, AutoTableDetector
from gmft.pdf_bindings import PyPDFium2Document
from PIL import Image       

detector = AutoTableDetector()
formatter = AutoTableFormatter()

def ingest_pdf(pdf_path): # produces list[CroppedTable]
    doc = PyPDFium2Document(pdf_path)
    tables = []
    for page in doc:
        tables += detector.extract(page)
    return tables, doc

def split_text_block(text_block):
    """
    Splits a given text block into an array of strings using '\n' as the delimiter.

    Args:
    text_block (str): The input text block to split.

    Returns:
    list: A list of strings split by the newline character.
    """
    # Split the text block by the newline delimiter
    return text_block.split('\n')

path = "/Users/sachinjeph/Desktop/biomarker/repo/assets/Sachin_M_23_2024_2 copy.pdf"
tables, doc = ingest_pdf(path)
# print("Table",tables)
# print("Doc",doc)
# print("Table1.txt=>",tables[0].text())
# print("Table1.txt=>",tables[0].image().show())
# img = Image.open('/Users/sachinjeph/Desktop/biomarker/repo/assets/single-page-medical-report-img.png')
# print(img)

# img.show()
completeText = ""
print(len(tables))
for table in tables:
    print(table.text())
    print("#######")
    # completeText += table.text()
    # table.image().show()

#create a list of rows from all the tables.
result = split_text_block(completeText)
print(result)

doc.close() # once you're done with the document



