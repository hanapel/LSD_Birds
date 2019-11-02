DROP TYPE ptaci_budovy;
CREATE TYPE ptaci_budovy AS (
id_species int
, speciesnameczech varchar
, vzd_1 float
, vzd_10 float
--, pocet_budov_v_bufferu_100 int
--, pocet_budov_v_bufferu_500 int
--, pocet_budov_v_bufferu_1000 int
);

WITH cetne AS (
   SELECT id_species--, count(*)
   FROM podklady.vzorek_lsd
   GROUP BY id_species
   HAVING count(*) > 1000
)
SELECT 
json_agg((
id_species
, speciesnameczech
, vzd_1
, vzd_10
--, pocet_budov_v_bufferu_100
--, pocet_budov_v_bufferu_500
--, pocet_budov_v_bufferu_1000
)::ptaci_budovy)


FROM
podklady.vzorek_lsd
LEFT JOIN LATERAL (
   SELECT
   vzorek_lsd.geom_spec_jtsk <-> wkb_geometry vzd_1
   FROM podklady.budovy
   WHERE (vzorek_lsd.geom_spec_jtsk <-> wkb_geometry) < 5000
   ORDER BY vzorek_lsd.geom_spec_jtsk <-> wkb_geometry
   LIMIT 1
) nejblizsibudova ON True
LEFT JOIN LATERAL (
   SELECT avg(vzd) vzd_10
   FROM
   (
      SELECT
      vzorek_lsd.geom_spec_jtsk <-> wkb_geometry vzd
      FROM podklady.budovy
      WHERE (vzorek_lsd.geom_spec_jtsk <-> wkb_geometry) < 5000
      ORDER BY vzorek_lsd.geom_spec_jtsk <-> wkb_geometry
      LIMIT 10
   ) dta
) deset_nejblizzsich_budov ON True
/*
LEFT JOIN LATERAL (
   SELECT count(*) pocet_budov_v_bufferu_100
   FROM podklady.budovy
   WHERE (vzorek_lsd.geom_spec_jtsk <-> wkb_geometry) <= 100
) buffer_100 ON True
LEFT JOIN LATERAL (
   SELECT count(*) pocet_budov_v_bufferu_500
   FROM podklady.budovy
   WHERE (vzorek_lsd.geom_spec_jtsk <-> wkb_geometry) <= 500
) buffer_500 ON True
LEFT JOIN LATERAL (
   SELECT count(*) pocet_budov_v_bufferu_1000
   FROM podklady.budovy
   WHERE (vzorek_lsd.geom_spec_jtsk <-> wkb_geometry) <= 1000
) buffer_1000 ON True
*/
WHERE id_species IN (
   SELECT id_species
   FROM cetne
) 
--LIMIT 10
\g /tmp/ptaci_baraci.json
