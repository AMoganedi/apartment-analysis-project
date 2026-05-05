from bs4 import BeautifulSoup
import pandas as pd
import requests
import time
import random
import re
import gc

session = requests.Session()
session.headers.update({"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36"})

def extract(page = "", session=session):
    url = f"url{page}"

    
    url_page = session.get(url)
    
    if url_page.status_code == 200:
        get_html = BeautifulSoup(url_page.text, "html.parser")
    
        return get_html
    else:
        return "Not url"

def transform(html, apartmentDatabase):
    
    container1 = html.find_all("span", itemprop=re.compile(r"\boffers\b"))
    
    price_list, type_list, location_list, bedroom_list, bathroom_list, space_list, size_list= [],  [], [], [], [], [], []
    
    if container1:
        
        
        for i in container1:
            price_tag = i.find("span", class_=re.compile(r"\bp24_price\b"))
            if price_tag:
                price = price_tag.text.replace("\n", "")
                price = price.replace("\r", "")
                price_list.append(price.strip())
            else:
                price_list.append(None)
            
            type_tag = i.find("span", class_=re.compile(r"\bp24_title\b"))
            if type_tag:
                type = type_tag.text.replace("\n", "")
                type_list.append(type.strip())
            else:
                type_list.append(None)
            
            location_tag = i.find("span", class_=re.compile(r"\bp24_location\b"))
            if location_tag:
                location_list.append(location_tag.text.strip())
            else:
                location_list.append(None)
                
                
    bedroom_containers = html.find_all("span", title=re.compile(r"\bBedrooms\b"))
    
    for bedroom_container in bedroom_containers:
        if bedroom_container:
            bedroom_container = bedroom_container.find("span").text.replace("\n", "")
            bedroom_list.append(bedroom_container.strip())
        else:
            bedroom_list.append(None)
            
    bathroom_containers = html.find_all("span", title=re.compile(r"\bBathrooms\b"))
    for bathroom_container in bathroom_containers:
        if bathroom_container:
            bathroom_container = bathroom_container.find("span").text.replace("\n", "")
            bathroom_list.append(bathroom_container.strip())
        else:
            bathroom_list.append(None)
            
    parking_space_containers = html.find_all("span", title=re.compile(r"\bParking Spaces\b"))
    for parking_space_container in parking_space_containers:
        if parking_space_container:
            parking_space_container = parking_space_container.find("span").text.replace("\n", "")
            space_list.append(parking_space_container.strip())
        else:
            space_list.append(None)
            
    floor_size_containers = html.find_all("span", title=re.compile(r"\bFloor Size\b"))
    for floor_size_container in floor_size_containers:
        if floor_size_container:
            floor_size_container = floor_size_container.find("span").text.replace("\n", "")
            size_list.append(floor_size_container.strip())
        else:
            size_list.append(None)
            
    for index in range(len(price_list)):
        
        if len(type_list) > index:
            property_type = type_list[index]
        else:
            property_type = None
            
        if len(location_list) > index:
            property_locations = location_list[index]
        else:
            property_locations = None

        if len(bedroom_list) > index:
            bedrooms = bedroom_list[index]
        else:
            bedrooms = None
            
        if len(bathroom_list) > index:
            bathrooms = bathroom_list[index]
        else:
            bathrooms = None
            
        if len(space_list) > index:
            parking_space = space_list[index]
        else:
            parking_space = None
            
        if len(size_list) > index:
            floor_size = size_list[index]
        else:
            floor_size = None
            
        if len(price_list) > index:
            property_price = price_list[index]
        else:
            property_price = None
        
        apartmant_data = {
            "Property_type": property_type,
            "Property_city": "Pritoria",
            "Property_location": property_locations,
            "Bedrooms": bedrooms,
            "Bathrooms": bathrooms,
            "Parking_space": parking_space,
            "Floor_size": floor_size,
            "Property_price_(per_month)": property_price
        }
        apartmentDatabase.append(apartmant_data)
    return apartmentDatabase


apartmentDatabase = []


for page in range(1, 209):
    html = extract(f"p{page}")
    transform(html, apartmentDatabase)
    del html
    gc.collect()
    print(page)
    time.sleep(random.uniform(3, 6))  
    
    
# print(apartmantDatabase)

df = pd.DataFrame(apartmentDatabase)
print(df)
df.to_csv("propertyDatabase.csv", index=False)