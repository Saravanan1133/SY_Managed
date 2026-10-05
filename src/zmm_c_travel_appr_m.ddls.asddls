@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Approver Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMM_C_TRAVEL_APPR_M
  provider contract transactional_query
  as projection on ZSY_I_TRAVEL_M
{
  key TravelId,
      AgencyId,
      CustomerId,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      Status,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _Agency,
      _Booking :redirected to composition child ZMM_C_BOOKING_APPR_M,
      _Currency,
      _Customer,
      _Status
}
