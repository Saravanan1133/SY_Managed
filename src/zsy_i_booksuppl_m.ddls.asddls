@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BookSuppl Interface Managed'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSY_I_BOOKSUPPL_M
  as select from zsy_booksuppl_m
  association        to parent ZSY_I_BOOKING_M as _Booking      on  $projection.TravelId  = _Booking.TravelId
                                                                and $projection.BookingId = _Booking.BookingId
  association [1..1] to ZSY_I_TRAVEL_M         as _Travel       on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement      as _Supplement   on  $projection.SupplementId = _Supplement.SupplementID
  association [1..1] to /DMO/I_SupplementText  as _SuplementTxt on  $projection.SupplementId   = _SuplementTxt.SupplementID
                                                                and _SuplementTxt.LanguageCode = $session.system_language
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      _Booking,
      _Travel,
      _Supplement,
      _SuplementTxt
}
