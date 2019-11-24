WITH cetne AS (
   SELECT id_species
   FROM podklady.vzorek_lsd
   GROUP BY id_species
   HAVING count(*) > 1000
)
SELECT
json_agg((
id_species
, speciesnameczech
, vzd_1
)::ptaci_reky)
FROM
podklady.vzorek_lsd
LEFT JOIN LATERAL (
   SELECT
   ST_Distance(vzorek_lsd.geom_spec_jtsk, "A01_Vodni_tok_CEVT".geom) vzd_1
   FROM podklady."A01_Vodni_tok_CEVT"
   WHERE ST_DWithin(vzorek_lsd.geom_spec_jtsk, "A01_Vodni_tok_CEVT".geom, 5000)
   ORDER BY ST_Distance(geom_spec_jtsk, "A01_Vodni_tok_CEVT".geom) DESC LIMIT 1
) nejblizsireka ON True
WHERE id_species IN (
   SELECT id_species
   FROM cetne)
;
