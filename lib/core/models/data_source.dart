enum DataSourceType { live, cached, dataset }

extension DataSourceTypeExtension on DataSourceType {
  String get label {
    switch (this) {
      case DataSourceType.live:
        return 'Live Data';
      case DataSourceType.cached:
        return 'Cached';
      case DataSourceType.dataset:
        return 'Dataset';
    }
  }
}
