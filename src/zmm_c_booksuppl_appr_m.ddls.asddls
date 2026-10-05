@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suppl. Approver Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_C_BOOKSUPPL_APPR_M
  as projection on ZSY_I_BOOKSUPPL_M
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZMM_C_BOOKING_APPR_M,
      _SuplementTxt,
      _Supplement,
      _Travel: redirected to ZMM_C_TRAVEL_APPR_M
}
