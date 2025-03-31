import '../enums/media_type.dart';

extension MediaTypeExtension on MediaType {
  String toApiString() {
    switch (this) {
      case MediaType.movie:
        return 'movie';
      case MediaType.tv:
        return 'tv';
    }
  }
}
