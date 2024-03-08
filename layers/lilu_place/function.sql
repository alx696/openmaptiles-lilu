CREATE OR REPLACE FUNCTION layer_lilu_place(bbox geometry, zoom_level int, pixel_width numeric)
RETURNS TABLE (name text, type text, rank int, geometry geometry) AS
$$
SELECT * FROM (
    -- 省,州
    SELECT name, type, cast(coalesce(nullif(capital,''),'0') as int) as rank, geometry FROM osm_lilu_place_point
    WHERE geometry && bbox
        AND zoom_level = 4
        AND type in ('state', 'province')

    UNION ALL

    -- 市,区,县
    SELECT name, type, cast(coalesce(nullif(capital,''),'0') as int) as rank, geometry FROM osm_lilu_place_point
    WHERE geometry && bbox
        AND zoom_level >= 5
        AND type = 'city'

    UNION ALL

    -- 乡,镇,街道
    -- suburb 似乎被滥用了?
    SELECT name, type, cast(coalesce(nullif(capital,''),'0') as int) as rank, geometry FROM osm_lilu_place_point
    WHERE geometry && bbox
        AND zoom_level >= 7
        AND type in ('town', 'suburb')

    UNION ALL

    -- 村,社区,小区,湾
    SELECT name, type, cast(coalesce(nullif(capital,''),'0') as int) as rank, geometry FROM osm_lilu_place_point
    WHERE geometry && bbox
        AND zoom_level >= 8
        AND type in ('village', 'hamlet', 'quarter', 'neighbourhood', 'isolated_dwelling')
) AS place_all;
$$ LANGUAGE SQL STABLE
-- STRICT
PARALLEL SAFE ;
