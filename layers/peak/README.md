# 说明

## mapping.yaml

文件定义从osm导入数据时, 取什么数据, 生成什么表. 在执行 `make import-osm area=asia/china/sichuan` 时就会应用, 执行后会生成加了前缀 `osm_` 的表, 例如 `osm_peak_point` .

```
tables:
  peak_point:
    type: point
    columns:
      - name: osm_id
        type: id
      - name: name
        key: name
        type: string
      - name: ele
        key: ele
        type: string
      - name: geometry
        type: geometry
    mapping:
      natural:
        - peak
```

注意 `mapping` 用于筛选数据, `natural` 对应的是osm数据中的tags属性名称.

## function.sql

文件定义一个函数, 供切片时使用. 并根据范围缩放像素信息, 按需查询图层需要的图层数据.

## peak.yaml

文件定义层的信息, 如id, 字段等. 注意文件名称必须与层的id一致, 否则无法自动生成样式! 需将 `mapping.yaml` 和 `function.sql` 配置其中以生效 . 在执行 `make import-osm` 或 `make import-sql` 时会应用. 文件需要添加到项目根文件夹 `openmaptiles.yaml` 的 `tileset:layers` 中才会生效!

## style.json

文件定义显示样式和层级.
