SELECT 
json_agg(dta)
FROM
podklady.dotcene_kvadraty, LATERAL 
(
   SELECT 
   kves.kategorie
   , sum(ST_Area(st_intersection(wkb_geometry, geom_jtsk))) plocha
   , dotcene_kvadraty.id
   FROM
   podklady.kves
   WHERE ST_Intersects(geom_jtsk, kves.wkb_geometry)
   GROUP BY kategorie, id
) dta 
