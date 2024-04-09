# Data Science Portfolio by Antonio Rendon
#Archivo para crear la version en modo consola de nuestra app

import requests

def obtener_ventas(fecha):
    url=f"http://127.0.0.1:8000/ventas/{fecha}"  #URL de FastAPI para consumir el servicio

    try:
        response=requests.get(url)
        response.raise_for_status()
        ventas=response.json()
        
        for venta in ventas:
            print(f"{venta['Retailer']} | Sales: {venta['Sales']} | Profit: {venta['Profit']}")
    except requests.RequestException as e:
        print(f"Error: {e}")    

fecha = input("Ingrese la fecha (YYYY-MM-DD): ")
obtener_ventas(fecha)

    

  
