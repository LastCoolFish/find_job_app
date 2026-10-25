/// What an analytics event is about: a vacancy or an order, with its id.
sealed class EventTarget {
  final int id;

  const EventTarget(this.id);
}

class VacancyTarget extends EventTarget {
  const VacancyTarget(super.id);
}

class OrderTarget extends EventTarget {
  const OrderTarget(super.id);
}

/// Matches `EventTypeEnum` on the backend.
enum EventType {
  viewStart('view_start'),
  viewEnd('view_end'),
  linkClick('link_click');

  final String apiName;

  const EventType(this.apiName);
}
