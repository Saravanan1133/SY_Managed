@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Approver Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_C_BOOKING_APPR_M
  as projection on ZSY_I_BOOKING_M
{
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _BookingStatus,
      _BookingSuppl : redirected to composition child ZMM_C_BOOKSUPPL_APPR_M,
      _Carrier,
      _Connection,
      _Customer,
      _Travel       : redirected to parent ZMM_C_TRAVEL_APPR_M
}
