# I-MED Procedure Q&A Assistant

## Overview

This project implements a simple grounded question-answering system over publicly available I-MED Radiology procedure pages.

The system scrapes procedure information from **i-med.com.au**, stores the extracted content locally, and allows users to ask questions about procedures. All answers are grounded in the scraped content.

The goal of this prototype is to demonstrate how a retrieval-based AI assistant could help patients or clinic staff quickly find information about imaging procedures such as preparation instructions, risks, duration, and results.

---

# System Architecture

The system follows a lightweight **retrieval-augmented question answering (RAG)** pipeline:

User question  
      ↓  
Query expansion  
      ↓  
TF-IDF retrieval over chunked procedure pages  
      ↓  
Lightweight reranking  
      ↓  
Sentence extraction from top chunks  
      ↓  
Grounded answer + source citation

The system consists of four main stages.

### 1. Scraping

Procedure pages are scraped from **i-med.com.au** using `requests` and `BeautifulSoup`.

The scraper:

- downloads each page
    
- extracts the main textual content
    
- stores structured records as JSON
    

Example output:

data/procedures.json

Each record contains:

- URL
    
- page title
    
- extracted text
    
- content length
    

---

### 2. Chunking

Procedure pages are split into smaller **text chunks** to improve retrieval accuracy.

Chunking helps because:

- long documents reduce retrieval precision
    
- smaller sections allow more relevant matches
    

Chunks are stored in:

data/chunks.json

Each chunk contains:

- chunk_id
    
- title
    
- source URL
    
- chunk text
    
- word count
    

---

### 3. Retrieval

User questions are matched against the chunk corpus using **TF-IDF vector similarity**.

The retrieval system includes:

- query expansion for common patient wording
    
- cosine similarity scoring
    
- result deduplication
    
- optional reranking based on query term matches
    

The top chunks are returned along with their **similarity scores**.

---

### 4. Grounded Answer Generation

The answer generator extracts the most relevant sentences from the retrieved chunks.

Important design choices:

- answers only use **retrieved text**
    
- no external knowledge is introduced
    
- answers include **source URLs**
    
- used chunks and similarity scores are displayed
    

This prevents hallucinated answers and ensures responses remain grounded in the scraped content.

---

# Project Structure

imed-ai-assignment  
│  
├── data  
│   ├── urls.txt  
│   ├── procedures.json  
│   └── chunks.json  
│  
├── src  
│   ├── scrape.py  
│   ├── chunk.py  
│   ├── retrieve.py  
│   └── answer.py  
│  
├── requirements.txt  
├── run.sh  
├── README.md  
└── ANSWERS.md

---

# Setup and Installation

### Requirements

- Python 3.9+
    
- pip
    

Install dependencies:

pip install -r requirements.txt

Dependencies include:

requests  
beautifulsoup4  
scikit-learn

---

# Running the System

## Simply run "./run.sh"

OR

### 1. Scrape procedure pages

python src/scrape.py

This reads URLs from:

data/urls.txt

and produces:

data/procedures.json

---

### 2. Generate chunks

python src/chunk.py

This produces:

data/chunks.json

---

### 3. Run the question-answering system

python src/answer.py

Example session:

Question: How do I prepare for an abdominal ultrasound?  
  
Answer:  
Abdomen ultrasound You will need to fast for six hours prior to the examination.  
  
Sources:  
- https://i-med.com.au/procedures/ultrasound  
  
Used chunks:  
- ultrasound_5  
  
Similarity score: 0.1301

Type `exit` to quit.

---

# Example Queries

5 example questions tested with the system:

Q: How do I prepare for an abdominal ultrasound?  

A: Abdomen ultrasound You will need to fast (have nothing to eat, drink, smoke or chew) for six hours prior to the examination. Vascular (blood vessel related) ultrasound Renal (kidney) arteries – You will need to fast (have nothing to eat or drink) for eight hours prior to the examination to ensure that the renal arteries are not covered by food or fluid. How do I prepare for an ultrasound?

Q: What are the risks of a CT scan?

A: Radiation exposure: As is the case with most tests and medications prescribed by your doctor, CT does have risks that cannot be avoided. Our staff are highly trained to minimise these risks by using the lowest possible radiation dose to achieve quality images that allow the radiologist to make an accurate diagnosis. As is commonly known, x-rays are a form of radiation and must be used carefully by trained professionals to decrease the risks involved.

Q: When can I get my MRI results?

A: In some cases, it can take up to a week or more to receive all results from your MRI. How do I get my results? It is very important that you discuss the results with the doctor who referred you so they can explain what the results mean for you.

Q: How long does a mammography take?

A: How long does mammography take? If you have breast implants, the mammography will take longer (approximately 30 minutes) because it takes more time to make sure clear images are taken. Standard diagnostic mammography takes between 10-15 minutes.

Q: When can I get my CT scan results?

A: The radiographer will not be able to give you any results after the CT scan; this is the responsibility of your doctor and the radiologist who interprets the images from the scan and provides a report to your doctor. If your results are urgent, or you have a same day appointment with your doctor we will arrange for your results to be available immediately following the scan. How do I get my results?


---

# Known Limitations

This prototype has several limitations:

### 1. Limited data source

The chatbot only answers questions based on scraped **procedure pages**. Questions about pricing, appointment booking, or clinic availability cannot be answered.

### 2. Directory pages not parsed structurally

Pages like the clinic finder contain structured listings, but the scraper extracts them as plain text rather than structured records.

### 3. Lexical retrieval

TF-IDF retrieval relies on keyword overlap. This can fail when the query uses different wording from the page content.

Example:

What is a DEXA scan?

The retriever matched procedure and preparation sections rather than the definition.

### 4. Sentence selection

Answers are constructed from extracted sentences rather than generated summaries, which can occasionally combine unrelated details from different sections.

---

# Possible Improvements

If extended further, the system could be improved by:

### Semantic retrieval

Replace TF-IDF with embedding-based retrieval.

### Section-aware chunking

Use page headings to split chunks more intelligently.

### Structured scraping

Extract structured information from pages like the clinic directory.

### Better answer synthesis

Generate more concise responses rather than concatenating extracted sentences.
