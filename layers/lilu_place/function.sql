CREATE OR REPLACE FUNCTION layer_lilu_place(bbox geometry, zoom_level int, pixel_width numeric)
RETURNS TABLE (name text, type text, rank int, geometry geometry) AS
$$

-- 市,区,县
SELECT name,
    type,
    case capital
            when 'yes' then 1
            else cast(COALESCE(substring(capital, '\D*(\d+)\D*'), '0') as int)
        end as rank,
    geometry
FROM osm_lilu_place_point
WHERE geometry && bbox
    AND zoom_level >= 4
    AND type = 'city'

UNION ALL

-- 乡,镇,街道
-- suburb 似乎被滥用了?
SELECT name,
    type,
    case capital
            when 'yes' then 1
            else cast(COALESCE(substring(capital, '\D*(\d+)\D*'), '0') as int)
        end as rank,
    geometry
FROM osm_lilu_place_point
WHERE geometry && bbox
    AND zoom_level >= 7
    AND type in ('town', 'suburb')

UNION ALL

-- 村,社区,小区,湾
SELECT name,
    type,
    case capital
            when 'yes' then 1
            else cast(COALESCE(substring(capital, '\D*(\d+)\D*'), '0') as int)
        end as rank,
    geometry
FROM osm_lilu_place_point
WHERE geometry && bbox
    AND zoom_level >= 8
    AND type in ('village', 'hamlet', 'quarter', 'neighbourhood', 'isolated_dwelling')

order by rank;
$$ LANGUAGE SQL STABLE
-- STRICT
PARALLEL SAFE ;
