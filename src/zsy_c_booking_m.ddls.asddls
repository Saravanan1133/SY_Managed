@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Projection Managed'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSY_C_BOOKING_M
  as projection on ZSY_I_BOOKING_M
{
  key TravelId,
  key BookingId,
      BookingDate,
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      @Semantics.text: true
      _Customer.LastName        as CustomerName,
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      @Semantics.text: true
      _Carrier.Name             as CarrierName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      @UI.textArrangement: #TEXT_ONLY
      @ObjectModel.text.element: [ 'BookingStatusTxt' ]
      BookingStatus,
      @Semantics.text: true
      _BookingStatus._Text.Text as BookingStatusTxt : localized,
      LastChangedAt,
      /* Associations */
      _BookingStatus,
      _BookingSuppl : redirected to composition child ZSY_C_BOOKSUPPL_M,
      _Carrier,
      _Connection,
      _Customer,
      _Travel       : redirected to parent ZSY_C_TRAVEL_M
}
