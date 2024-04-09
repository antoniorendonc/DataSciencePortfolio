# Data Sciente Portfolio by Antonio Rendon
# Archivo principal para la construccion de la API

from fastapi import FastAPI, HTTPException
from google.cloud import bigquery
import os

app = FastAPI()

#Cambialo por tu archivo key de BigQuery
os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="adidas-project-415820-7cc8e0f5c4b0.json"

client = bigquery.Client()

@app.get("/ventas/{fecha}")     #EndPoint
def obtener_ventas(fecha: str):
    query=f"""SELECT InvDate, Retailer, SUM(TotalSales) AS Sales, SUM(OpProfit) As Profit
    FROM `adidas-project-415820.adidas_ds.sales_2020_2021` 
    WHERE InvDate ='{fecha}'
    GROUP BY InvDate,Retailer"""

    try:
        query_job=client.query(query)
        results=query_job.result()

        ventas=[dict(row) for row in results]

        return ventas
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
