# import nougat
# from nougat import extract

# print(nougat.__version__)


# pdf_path = "/Users/sachinjeph/Desktop/biomarker/repo/assets/single-page-medical-report-img.pdf"
# extracted_data = extract(pdf_path)

# # Example: Filter out tables
# tables = extracted_data.get('tables', [])
# print(tables)

# import deepdoctection as dd
# from IPython.core.display import HTML
# from matplotlib import pyplot as plt

# analyzer = dd.get_dd_analyzer()  # instantiate the built-in analyzer similar to the Hugging Face space demo

# df = analyzer.analyze(path = "/path/to/your/doc.pdf")  # setting up pipeline
# df.reset_state()                 # Trigger some initialization

# doc = iter(df)
# page = next(doc) 

# image = page.viz()
# plt.figure(figsize = (25,17))
# plt.axis('off')
# plt.imshow(image)

# from deepdoctection import get_dd_parser
# from deepdoctection.pipe import PdfPlumberPdfParser
# from deepdoctection.dataflow import DataFlowFromList

# # Create a DeepDoctection Parser
# dd_parser = get_dd_parser()

# # Load your PDF file into a list of pages
# pdf_file_path = "/Users/sachinjeph/Desktop/biomarker/repo/assets/single-page-medical-report-img.pdf"
# pdf_parser = PdfPlumberPdfParser()

# # Parse the PDF file
# with pdf_parser:
#     pdf_parser.apply_file(pdf_file_path)
#     pdf_pages = pdf_parser.get_pages()

# # Create DataFlow from parsed PDF
# df = DataFlowFromList(pdf_pages)

# # Pass the DataFlow through the DeepDoctection parser pipeline
# parsed_result = dd_parser.predict_dataflow(df)

# # Now parsed_result contains the detected elements, including tables
# for result in parsed_result:
#     tables = result.get_tables()  # Extracts detected tables
#     for table in tables:
#         print(f"Detected table with {len(table.rows)} rows and {len(table.columns)} columns")


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

path1 = "/Users/sachinjeph/Desktop/biomarker/repo/assets/single-page-medical-report-img.pdf"
path2 = "/Users/sachinjeph/Desktop/biomarker/repo/assets/Sachin_M_23_2024_2 copy.pdf"
tables, doc = ingest_pdf(path2)
# print("Table",tables)
# print("Doc",doc)
# print("Table1.txt=>",tables[0].text())
# print("Table1.txt=>",tables[0].image().show())
# img = Image.open('/Users/sachinjeph/Desktop/biomarker/repo/assets/single-page-medical-report-img.png')
# print(img)

# img.show()
print(len(tables))
for table in tables:
    table.json()
    # table.image().show()

doc.close() # once you're done with the document



