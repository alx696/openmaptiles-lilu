-- 表名来自 mapping.yaml 中的 tables 定义， 需要加上 osm_ 前缀.
-- case转换是为了适应样式中的icon.

CREATE OR REPLACE FUNCTION layer_lilu_poi(bbox geometry, zoom_level int, pixel_width numeric)
RETURNS TABLE (geometry geometry, name text, type text) AS
$$
SELECT geometry,name,
    case
        when type = 'camp_site' then 'camping'
        when type = 'picnic_site' then 'picnic'
        when type = 'attraction' then 'photo'
        else type
    end
FROM (
    -- 8级:医院,宗教
    SELECT geometry, name, type FROM osm_lilu_poi_point
    WHERE geometry && bbox
        AND zoom_level >= 8
        AND type in ('hospital', 'place_of_worship')

    UNION ALL

    -- 9级:景点
    SELECT geometry, name, type FROM osm_lilu_poi_point
    WHERE geometry && bbox
        AND zoom_level >= 9
        AND type in ('attraction')

    UNION ALL

    -- 10级以上:加油站,营地,野餐地
    SELECT geometry, name, type FROM osm_lilu_poi_point
    WHERE geometry && bbox
        AND zoom_level >= 10
        AND type in ('fuel', 'camp_site', 'picnic_site')
) AS x;
$$ LANGUAGE SQL STABLE
-- STRICT
PARALLEL SAFE ;
