# -*- coding: utf-8 -*-
"""
Created on Thu Jun 27 19:40:53 2024

@author: Aston
"""
#! pip install esgf-pyclient==0.3.0
#!pip install requests-cache==0.4.1
from pyesgf.search import SearchConnection
import os
import requests_cache
requests_cache.core.CachedSession
import requests
from tqdm import tqdm
import xarray as xr
requests_cache.core.CachedSession
lista_modelos= ['ACCESS-CM2','ACCESS-ESM1-5']
#,'AWI-CM-1-1-MR','BCC-CSM2-MR',
#'CAMS-CSM1-0','CAS-ESM2-0','CMCC-CM2-SR5','CMCC-ESM2','CanESM5',
#'EC-Earth3','EC-Earth3-Veg','EC-Earth3-Veg-LR','FGOALS-f3-L',
#'GFDL-ESM4','IITM-ESM','INM-CM4-8','INM-CM5-0','IPSL-CM6A-LR',
#'KACE-1-0-G','MIROC6','MPI-ESM1-2-HR','MPI-ESM1-2-LR','MRI-ESM2-0',
#'NESM3']
conn = SearchConnection('https://esgf-node.llnl.gov/esg-search', distrib=True)
ctx = conn.new_context(project='CMIP6',
experiment_id=['historical'],
realm=['atmos'],
variable='uas',
frequency='mon',
source_type=['AOGCM'],
variant_label='r1i1p1f1',
source_id= lista_modelos
)
ctx.hit_count
ctx.facet_counts['source_id'].keys()
# Obtain urls lists
lista_urls=[]
for i in range(len(ctx.search())):
    try:
        result = ctx.search()[i]
        print(result.dataset_id,'..............ok')

        lista_urls.append(result)
    except:
        pass
print('-------------------------------')
print('Lista finales')
lista_urls
# Download the first model for example
tr=[x for x in lista_urls if lista_modelos[0] in x.dataset_id]
files = tr[0].file_context().search()
lista=[]
for i in range(len(files)):
    lista.append(files[i].opendap_url)
print(lista)
ds = xr.open_mfdataset([x for x in lista], chunks={'time': 120}, combine='nested', concat_dim='time')
#ds_mei=ds.where((ds.lon>=-90+360) & (ds.lon<=-60+360) &(ds.lat>=6) & (ds.lat<=25),drop=True) ###edited by myself
ds_mei=ds.sel(bnds=1)
# Plot example
data = ds_mei.uas[0,:,:]
print(type(data))
data.plot.contourf(levels=35,cmap='jet',add_colorbar=True, x='lon',y='lat');
# Write the netcdf to a route
ds_mei.to_netcdf('uas_'+lista_modelos[0]+'_Historical.nc',format='NETCDF3_64BIT', mode='w')
