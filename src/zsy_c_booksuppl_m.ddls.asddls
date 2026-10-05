@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BookSuppl Projection Managed'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSY_C_BOOKSUPPL_M
  as projection on ZSY_I_BOOKSUPPL_M
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text.element: [ 'SupplTxt' ]
      SupplementId,
      @Semantics.text: true
      _SuplementTxt.Description as SupplTxt,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZSY_C_BOOKING_M,
      _SuplementTxt,
      _Supplement,
      _Travel  : redirected to ZSY_C_TRAVEL_M
}
