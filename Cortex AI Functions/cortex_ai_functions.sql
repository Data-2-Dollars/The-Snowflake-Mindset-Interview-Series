-- String completions

create database CORTEX_AI_FUNC_TUTORIAL;

SELECT AI_COMPLETE('llama3.1-8b', 'What are large language models?');


SELECT AI_COMPLETE(
    model => 'llama3.1-8b',
    prompt => 'how does a snowflake get its unique pattern?',
    model_parameters => {
        'temperature': 0.1,
        'max_tokens': 10
    }
);

-- image information

select AI_COMPLETE('claude-sonnet-4-6',
'Extract the kitched appliaces identified in this image. Respond in JSON only with the identified appliances.',
TO_FILE('@CORTEX_AI_FUNC_TUTORIAL.PUBLIC.IMAGE_PROCESSING_STG','kitchen-remodel.png'));



SELECT AI_CLASSIFY('One day I will see the world', ['travel', 'cooking']);

SELECT AI_CLASSIFY(
  'One day I will see the world and learn to cook my favorite dishes',
  ['travel', 'cooking', 'reading', 'driving'],
  {'output_mode': 'multi'}
);

WITH kitchen_pictures AS (
  SELECT
      TO_FILE('@CORTEX_AI_FUNC_TUTORIAL.PUBLIC.IMAGE_PROCESSING_STG', RELATIVE_PATH) AS img
  FROM DIRECTORY('@IMAGE_PROCESSING_STG')
)
SELECT
*,
AI_CLASSIFY(img, ['dessert', 'drink', 'main dish', 'side dish','cooking area']):labels AS classification
FROM kitchen_pictures;


WITH staged_docs AS (
  SELECT TO_FILE('@CORTEX_AI_FUNC_TUTORIAL.PUBLIC.IMAGE_PROCESSING_STG', RELATIVE_PATH) AS doc FROM DIRECTORY('@IMAGE_PROCESSING_STG')
)
SELECT doc, AI_CLASSIFY(doc, ['invoice', 'contract', 'lab_report']):labels AS classification
FROM staged_docs;

---AI_FILTER
Select AI_FILTER('Is UK in Europe?');


Select AI_FILTER('America won all the battles till date?');


with pic As(
  SELECT TO_FILE('@CORTEX_AI_FUNC_TUTORIAL.PUBLIC.IMAGE_PROCESSING_STG', RELATIVE_PATH) AS img 
  FROM DIRECTORY('@IMAGE_PROCESSING_STG')
)
SELECT
  FL_GET_RELATIVE_PATH(img) AS file_path 
FROM pic
WHERE FL_IS_IMAGE(img)
  AND AI_FILTER('Is this a picture of a human?', img);


  --AI_AGG

  WITH reviews AS (
            SELECT 'The restaurant was excellent.' AS review, 'Pizza' AS menu_item
  UNION ALL SELECT 'Excellent! I loved the pizza!', 'Pizza'
  UNION ALL SELECT 'It was great, but the service was meh.', 'Burger'
  UNION ALL SELECT 'Mediocre food and mediocre service', 'Pancakes'
)
SELECT AI_AGG('Menu Item: ' || menu_item || '\nReview: ' || review,
              'Summarize the restaurant reviews for potential consumers')
  FROM reviews;

--AI_EMBED

SELECT AI_EMBED('snowflake-arctic-embed-l-v2.0', 'hello world');

SELECT AI_EMBED('voyage-multimodal-3',
        TO_FILE('@CORTEX_AI_FUNC_TUTORIAL.PUBLIC.IMAGE_PROCESSING_STG', 'kitchen-remodel.png'));


--AI_EXTRACT

SELECT AI_EXTRACT(
  file => TO_FILE('@CORTEX_AI_FUNC_TUTORIAL.PUBLIC.IMAGE_PROCESSING_STG', 'pdf_freelance_invoice_template.pdf'),
  responseFormat => {'name': 'What is the country?', 'date': 'What is the issued date?','amount': 'what is the total amount due?'},
  scores => TRUE
);


--AI_SENTIMENT
SELECT AI_SENTIMENT('I recently purchased the iPhone Air from Amazon, and I am absolutely thrilled with my experience! Right from the moment I unboxed it, the sleek design and lightweight feel were impressive. The size of the phone is truly stand out, making everyday tasks smooth and enjoyable. The performance is lightning-fast, the display is crisp, and the battery life easily lasts through a busy day.


Overall, the iPhone Air has exceeded my expectations in every way. I would confidently give it 5 stars and highly recommend it to anyone looking for a premium smartphone experience.');

select AI_SENTIMENT('Worset phone ever i bought phone stop working on very 1 st day of purchasing we call they said it will replace by the center but they didn’t replace they take phone for 7 days and i have to buy a new phone on same day from the store but coming back i got only 70000 of that phone and phone has a manufacturing defaults i feel this going a big scam straight forward within few hour i have lost 40k value when defaults is manufacturing why amazon didn’t check the quality of their products it gonna be the last time when i buy phone from online i have trust issues now as I couldn’t recover my loss');


---AI_SIMILARITY

SELECT AI_SIMILARITY('I like this dish', 'and the dish is very good');

SELECT AI_SIMILARITY(TO_FILE('@CORTEX_AI_FUNC_TUTORIAL.PUBLIC.IMAGE_PROCESSING_STG', 'kitchen-remodel.png'), TO_FILE('@CORTEX_AI_FUNC_TUTORIAL.PUBLIC.IMAGE_PROCESSING_STG', 'kitchen-remodel.png'));


---AI_TRANSCRIBE

Select AI_TRANSCRIBE(TO_FILE('@CORTEX_AI_FUNC_TUTORIAL.PUBLIC.IMAGE_PROCESSING_STG', 'Closer The Chainsmokers 128 Kbps.mp3'));


---AI_PARSE_DOCUMENT

Select AI_PARSE_DOCUMENT(TO_FILE('@CORTEX_AI_FUNC_TUTORIAL.PUBLIC.IMAGE_PROCESSING_STG', 'pdf_freelance_invoice_template.pdf'));


--aI_redact

Select AI_REDACT('{
  "content": "FROM Your Name\nINVOICE\n1234 Your Street INV-10012 · Issued 26/3/2021 · Due 25/4/2021 City, California\n90210\nUnited States\n1-888-123-4567\nBILLED TO AMOUNT DUE Your Client\n1234 Clients Street\n$1,699.48\nCity, California\n90210\nUnited States\n1-888-123-8910\nDESCRIPTION HOURS RATE AMOUNT\nServices 10 $55.00 $550.00\nConsulting 15 $75.00 $1,125.00\nMaterials 1 $123.39 $123.39\nSubtotal $1,798.39\nDiscount -$179.84\nTax +$80.93\nTotal $1,699.48\nNOTES\nThank you for your business!\nPAYMENT TERMS\nPlease pay within 30 days using the link in your invoice email.\nInvoicer.ai",
  "metadata": {
    "pageCount": 1
  }
}');

---AI_TRANSLATE

Select AI_TRANSLATE('Hello how r u?', 'en', 'hi');


Select SNOWFLAKE.CORTEX.SUMMARIZE('{
  "content": "FROM Your Name\nINVOICE\n1234 Your Street INV-10012 · Issued 26/3/2021 · Due 25/4/2021 City, California\n90210\nUnited States\n1-888-123-4567\nBILLED TO AMOUNT DUE Your Client\n1234 Clients Street\n$1,699.48\nCity, California\n90210\nUnited States\n1-888-123-8910\nDESCRIPTION HOURS RATE AMOUNT\nServices 10 $55.00 $550.00\nConsulting 15 $75.00 $1,125.00\nMaterials 1 $123.39 $123.39\nSubtotal $1,798.39\nDiscount -$179.84\nTax +$80.93\nTotal $1,699.48\nNOTES\nThank you for your business!\nPAYMENT TERMS\nPlease pay within 30 days using the link in your invoice email.\nInvoicer.ai",
  "metadata": {
    "pageCount": 1
  }
}');

