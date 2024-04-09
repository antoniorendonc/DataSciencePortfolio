# Data Science Portfolio by Antonio Rendon
# Archivo para construir la version GUI de nuestro proyecto

import tkinter as tk
from tkinter import messagebox, ttk
from tkcalendar import DateEntry  # Necesitarás instalar tkcalendar: pip install tkcalendar
import requests
import locale
import os

# Establece la configuración local para usar en el formato de moneda
locale.setlocale(locale.LC_ALL, '')

# Tema Claro
bg_color = "#FFFFFF"  # Fondo blanco
text_color = "#000000"  # Texto negro
btn_color = "#F0F0F0"  # Botones de un gris claro
entry_bg_color = "#FFFFFF"  # Fondo de entrada blanco
entry_fg_color = "#000000"  # Texto de entrada negro
font = ("Arial", 12)

# Función para obtener ventas desde la API y mostrar en la ventana
def obtener_ventas():
    fecha = entry_fecha.get_date().strftime("%Y-%m-%d")  # Obtener la fecha seleccionada en formato YYYY-MM-DD
    url = f"http://localhost:8000/ventas/{fecha}"
    try:
        response = requests.get(url)
        response.raise_for_status()
        ventas = response.json()

        # Limpia el widget de texto antes de mostrar nuevos resultados
        text_widget.delete('1.0', tk.END)

        # Encabezados
        text_widget.insert(tk.END, f"{'Retailer':<10}{'Sales':>15}{'Profit':>15}\n")
        text_widget.insert(tk.END, "-"*40 + "\n")

        # Formatear y mostrar la salida en el widget de texto
        for venta in ventas:
            sales_formatted = locale.currency(venta['Sales'], grouping=True)
            profit_formatted = locale.currency(venta['Profit'], grouping=True)
            text_widget.insert(tk.END, f"{venta['Retailer']:<10}{sales_formatted:>15}{profit_formatted:>15}\n")
    except requests.RequestException as e:
        messagebox.showerror("Error", str(e), parent=root)


# Crear la ventana principal
root = tk.Tk()
root.title("Consulta de Ventas")
root.configure(bg=bg_color)

# Cargar y mostrar el logo (asegúrate de que la ruta al logo es correcta)
logo_path = os.path.join(os.path.dirname(__file__), 'logo_adidas.png')  # Ajusta el nombre del archivo si es necesario
logo_image = tk.PhotoImage(file=logo_path)
logo_image = logo_image.subsample(2, 2)  # Ajusta los valores según sea necesario
logo_label = tk.Label(root, image=logo_image, bg=bg_color)
logo_label.pack(pady=10)

# Configuración de estilo global para ttk
style = ttk.Style(root)
style.theme_use("clam")

# Configura los colores del tema
style.configure(".", background=bg_color, foreground=text_color, font=font)
style.configure("TButton", background=btn_color, foreground=text_color, font=font, borderwidth=1)
style.map("TButton", background=[("active", btn_color)], foreground=[("active", text_color)])
style.configure("TEntry", fieldbackground=entry_bg_color, foreground=entry_fg_color, borderwidth=1)
style.configure("TLabel", background=bg_color, foreground=text_color)

# Selector de fecha
entry_fecha = DateEntry(root, width=12, background=entry_bg_color, foreground=entry_fg_color, borderwidth=2, date_pattern='y-mm-dd')
entry_fecha.pack(pady=5)

# Botón de envío
button_consultar = ttk.Button(root, text="Consultar Ventas", command=obtener_ventas)
button_consultar.pack(pady=10)

# Widget de texto para mostrar las ventas
text_widget = tk.Text(root, height=10, width=48, bg="#FFFFFF", fg=text_color)
text_widget.pack(pady=10)

# Ejecutar la aplicación
root.mainloop()
