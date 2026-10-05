@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Interface Managed'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSY_I_BOOKING_M
  as select from zsy_booking_m
  association        to parent ZSY_I_TRAVEL_M    as _Travel        on  $projection.TravelId = _Travel.TravelId
  composition [0..*] of ZSY_I_BOOKSUPPL_M        as _BookingSuppl
  association [1..1] to /DMO/I_Carrier           as _Carrier       on  $projection.CarrierId = _Carrier.AirlineID
  association [1..1] to /DMO/I_Customer          as _Customer      on  $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Connection        as _Connection    on  $projection.ConnectionId = _Connection.ConnectionID
                                                                   and $projection.CarrierId    = _Connection.AirlineID
  association [1..1] to /DMO/I_Booking_Status_VH as _BookingStatus on  $projection.BookingStatus = _BookingStatus.BookingStatus
{
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,
      _Travel,
      _BookingSuppl,
      _Carrier,
      _Customer,
      _Connection,
      _BookingStatus
}
