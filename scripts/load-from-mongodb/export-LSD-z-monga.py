#!/usr/bin/python

from pymongo import MongoClient
import simplejson
import osgeo.ogr as ogr
import osgeo.osr as osr

#pripojim se na db
url = 'mongodb://%s:%s@%s:%s/%s'%(username, pwd, host, port, db)

con=MongoClient(url)
db=con.get_database()
col=db.localities

#pripravim vystupni format
#https://pcjericks.github.io/py-gdalogr-cookbook/layers.html

drv = ogr.GetDriverByName("ESRI shapefile")
data_source = drv.CreateDataSource("transekty.shp")

# create the spatial reference, WGS84
srs = osr.SpatialReference()
srs.ImportFromEPSG(4326)

# create the layer
layer = data_source.CreateLayer("localities", srs, ogr.wkbMultiLineString)

# Add the fields we're interested in
field_id = ogr.FieldDefn("id", ogr.OFTString)
field_id.SetWidth(24)
layer.CreateField(field_id)
field_owners = ogr.FieldDefn("owners", ogr.OFTString)
field_owners.SetWidth(255)
layer.CreateField(field_owners)
layer.CreateField(ogr.FieldDefn('created', ogr.OFTDate))
field_name = ogr.FieldDefn("name", ogr.OFTString)
field_name.SetWidth(10)
layer.CreateField(field_name)
field_key = ogr.FieldDefn("key", ogr.OFTString)
field_key.SetWidth(24)
layer.CreateField(field_key)
layer.CreateField(ogr.FieldDefn('path', ogr.OFTInteger))


data = col.find({"closed":True, "current":True},{"_id": 1, "permissions.owners": 1,
    "created": 1, "name": 1, "key": 1, "path1": 1, "path2": 1})


for rec in data:
    #print(rec)
    for path in [1,2]:
        feature = ogr.Feature(layer.GetLayerDefn())
        feature.SetField("id", str(rec["_id"]))
        feature.SetField("owners", ', '.join(rec["permissions"]["owners"]))
        feature.SetField("created", str(rec["created"]))
        feature.SetField("name", rec["name"])
        feature.SetField("key", rec["key"])
        feature.SetField("path", path)


        geom = ogr.Geometry(ogr.wkbLineString)
        pp="path"+str(path)

        for point in rec[pp]:
            geom.AddPoint(point["longitude"], point["latitude"])
            #print(point)


        feature.SetGeometry(geom)
        layer.CreateFeature(feature)
        feature.Destroy()



data_source.Destroy()
