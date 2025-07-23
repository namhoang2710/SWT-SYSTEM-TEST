//
//  SmokingCessation+Icons.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import UIKit

public final class BundleSmokingCessation {
    public static let bundle: Bundle = Bundle(for: BundleSmokingCessation.self)
}

extension UIImage {
    convenience init?(iconNamed: String) {
        self.init(named: iconNamed, in: BundleSmokingCessation.bundle, compatibleWith: nil)
    }
}

public extension SmokingCessation {
    // MARK: - icon `Exit`
    var iconExit: UIImage? { UIImage(iconNamed: "ic_exit") }
    var iconExitInverse: UIImage? { UIImage(iconNamed: "ic_exit_inverse") }

    // MARK: - icon `Add`
    var iconAdd: UIImage? { UIImage(iconNamed: "ic_add") }
    var iconAddInverse: UIImage? { UIImage(iconNamed: "ic_add_inverse") }

    // MARK: - icon `Arrow`
    var iconArrowDown: UIImage? { UIImage(iconNamed: "ic_arrow_down") }
    var iconArrowDownInverse: UIImage? { UIImage(iconNamed: "ic_arrow_down_inverse") }
    var iconArrowLeft: UIImage? { UIImage(iconNamed: "ic_arrow_left") }
    var iconArrowLeftInverse: UIImage? { UIImage(iconNamed: "ic_arrow_left_inverse") }
    var iconArrowRight: UIImage? { UIImage(iconNamed: "ic_arrow_right") }
    var iconArrowRightInverse: UIImage? { UIImage(iconNamed: "ic_arrow_right_inverse") }
    var iconArrowUp: UIImage? { UIImage(iconNamed: "ic_arrow_up") }
    var iconArrowUpInverse: UIImage? { UIImage(iconNamed: "ic_arrow_up_inverse") }

    // MARK: - icon `Auto Circle`
    var iconAutoCircle: UIImage? { UIImage(iconNamed: "ic_auto_circle") }
    var iconAutoCircleInverse: UIImage? { UIImage(iconNamed: "ic_auto_circle_inverse") }

    // MARK: - icon `Calendar`
    var iconCalendar: UIImage? { UIImage(iconNamed: "ic_calendar") }
    var iconCalendarInverse: UIImage? { UIImage(iconNamed: "ic_calendar_inverse") }

    // MARK: - icon `Camera`
    var iconCamera: UIImage? { UIImage(iconNamed: "ic_camera") }
    var iconCameraInverse: UIImage? { UIImage(iconNamed: "ic_camera_inverse") }

    // MARK: - icon `cancel filled`
    var iconCancelFilled: UIImage? { UIImage(iconNamed: "ic_cancel_filled") }
    var iconCancelFilledInverse: UIImage? { UIImage(iconNamed: "ic_cancel_filled_inverse") }

    // MARK: - icon `cancel stroke`
    var iconCancelStroked: UIImage? { UIImage(iconNamed: "ic_cancel_stroked") }
    var iconCancelStrokedInverse: UIImage? { UIImage(iconNamed: "ic_cancel_stroked_inverse") }

    // MARK: - icon `Check Circle`
    var iconCheckCircle: UIImage? { UIImage(iconNamed: "ic_check_circle") }
    var iconCheckCircleInverse: UIImage? { UIImage(iconNamed: "ic_check_circle_inverse") }

    // MARK: - icon `chevron`
    var iconChevronDown: UIImage? { UIImage(iconNamed: "ic_chevron_down") }
    var iconChevronDownInverse: UIImage? { UIImage(iconNamed: "ic_chevron_down_inverse") }
    var iconChevronUp: UIImage? { UIImage(iconNamed: "ic_chevron_up") }
    var iconChevronUpInverse: UIImage? { UIImage(iconNamed: "ic_chevron_up_inverse") }
    var iconChevronLeft: UIImage? { UIImage(iconNamed: "ic_chevron_left") }
    var iconChevronLeftInverse: UIImage? { UIImage(iconNamed: "ic_chevron_left_inverse") }
    var iconChevronRight: UIImage? { UIImage(iconNamed: "ic_chevron_right") }
    var iconChevronRightInverse: UIImage? { UIImage(iconNamed: "ic_chevron_right_inverse") }

    // MARK: - icon `coin`
    var iconCoin: UIImage? { UIImage(iconNamed: "ic_coin") }
    var iconCoinInverse: UIImage? { UIImage(iconNamed: "ic_coin_inverse") }

    // MARK: - icon `done`
    var iconDone: UIImage? { UIImage(iconNamed: "ic_done") }
    var iconDoneInverse: UIImage? { UIImage(iconNamed: "ic_done_inverse") }

    // MARK: - icon `edit`
    var iconEdit: UIImage? { UIImage(iconNamed: "ic_edit") }
    var iconEditInverse: UIImage? { UIImage(iconNamed: "ic_edit_inverse") }

    // MARK: - icon `error`
    var iconError: UIImage? { UIImage(iconNamed: "ic_error") }
    var iconErrorInverse: UIImage? { UIImage(iconNamed: "ic_error_inverse") }

    // MARK: - icon `filled check circle`
    var iconFilledCheckCircle: UIImage? { UIImage(iconNamed: "ic_filled_check_circle") }
    var iconFilledCheckCircleInverse: UIImage? { UIImage(iconNamed: "ic_filled_check_circle_inverse") }

    // MARK: - icon `unCheck circle`
    var iconUncheckedCircle: UIImage? { UIImage(iconNamed: "ic_selector_uncheck") }
    // MARK: - icon `heart`
    var iconHeart: UIImage? { UIImage(iconNamed: "ic_heart") }
    var iconHeartInverse: UIImage? { UIImage(iconNamed: "ic_heart_inverse") }

    // MARK: - icon `Help`
    var iconHelp: UIImage? { UIImage(iconNamed: "ic_help") }
    var iconHelpInverse: UIImage? { UIImage(iconNamed: "ic_help_inverse") }

    // MARK: - icon `Money`
    var iconMoney: UIImage? { UIImage(iconNamed: "ic_money") }
    var iconMoneyInverse: UIImage? { UIImage(iconNamed: "ic_money_inverse") }

    // MARK: - icon `Money in`
    var iconMoneyIn: UIImage? { UIImage(iconNamed: "ic_money_in") }
    var iconMoneyInInverse: UIImage? { UIImage(iconNamed: "ic_money_in_inverse") }

    // MARK: - icon `Money out`
    var iconMoneyOut: UIImage? { UIImage(iconNamed: "ic_money_out") }
    var iconMoneyOutInverse: UIImage? { UIImage(iconNamed: "ic_money_out_inverse") }

    // MARK: - icon `More`
    var iconMore: UIImage? { UIImage(iconNamed: "ic_more") }
    var iconMoreInverse: UIImage? { UIImage(iconNamed: "ic_more_inverse") }

    // MARK: - icon `Percentage`
    var iconPercentage: UIImage? { UIImage(iconNamed: "ic_percentage") }
    var iconPercentageInverse: UIImage? { UIImage(iconNamed: "ic_percentage_inverse") }

    // MARK: - icon `Safebox`
    var iconSafebox: UIImage? { UIImage(iconNamed: "ic_safebox") }
    var iconSafeboxInverse: UIImage? { UIImage(iconNamed: "ic_safebox_inverse") }

    // MARK: - icon `Saving`
    var iconSaving: UIImage? { UIImage(iconNamed: "ic_saving") }
    var iconSavingInverse: UIImage? { UIImage(iconNamed: "ic_saving_inverse") }

    // MARK: - icon `Star`
    var iconStar: UIImage? { UIImage(iconNamed: "ic_star") }
    var iconStarInverse: UIImage? { UIImage(iconNamed: "ic_star_inverse") }

    // MARK: - icon `Target`
    var iconTarget: UIImage? { UIImage(iconNamed: "ic_target") }
    var iconTargetInverse: UIImage? { UIImage(iconNamed: "ic_target_inverse") }

    // MARK: - icon `Transfer`
    var iconTransfer: UIImage? { UIImage(iconNamed: "ic_transfer") }
    var iconTransferInverse: UIImage? { UIImage(iconNamed: "ic_transfer_inverse") }

    // MARK: - icon `Warning`
    var iconWarning: UIImage? { UIImage(iconNamed: "ic_warning") }
    var iconWarningInverse: UIImage? { UIImage(iconNamed: "ic_warning_inverse") }

    // MARK: - icon `External`
    var iconExternal: UIImage? { UIImage(iconNamed: "ic_external") }
    var iconExternalInverse: UIImage? { UIImage(iconNamed: "ic_external_inverse") }

    // MARK: - icon `QuestionMark`
    var iconQuestionMark: UIImage? { UIImage(iconNamed: "ic_question_mark") }
    var iconQuestionMarkInverse: UIImage? { UIImage(iconNamed: "ic_question_mark_inverse") }

    // MARK: - icon `Repeat`
    var iconRepeat: UIImage? { UIImage(iconNamed: "ic_repeat") }
    var iconRepeatInverse: UIImage? { UIImage(iconNamed: "ic_repeat_inverse") }

    // MARK: - icon `Share`
    var iconShare: UIImage? { UIImage(iconNamed: "ic_share") }
    var iconShareInverse: UIImage? { UIImage(iconNamed: "ic_share_inverse") }

    // MARK: - icon `Support`
    var iconSupport: UIImage? { UIImage(iconNamed: "ic_support") }
    var iconSupportInverse: UIImage? { UIImage(iconNamed: "ic_support_inverse") }

    // MARK: - icon `Clock`
    var iconClock: UIImage? { UIImage(iconNamed: "ic_clock") }
    var iconClockInverse: UIImage? { UIImage(iconNamed: "ic_clock_inverse") }

    // MARK: - icon `Splashscreen Logos`
    var iconGroupLogo: UIImage? { UIImage(iconNamed: "ic_group_logos") }

    // MARK: - icon `Governement ID`
    var iconGovernement: UIImage? { UIImage(iconNamed: "ic_governement") }
    var iconGovernementInverse: UIImage? { UIImage(iconNamed: "ic_governement_inverse") }

    // MARK: - icon `Passport ID`
    var iconPassport: UIImage? { UIImage(iconNamed: "ic_passport") }
    var iconPassportInverse: UIImage? { UIImage(iconNamed: "ic_passport_inverse") }

    // MARK: - icon `Postal ID`
    var iconPostal: UIImage? { UIImage(iconNamed: "ic_postal") }
    var iconPostalInverse: UIImage? { UIImage(iconNamed: "ic_postal_inverse") }

    // MARK: - icon `UM ID`
    var iconUmid: UIImage? { UIImage(iconNamed: "ic_umid") }
    var iconUmidInverse: UIImage? { UIImage(iconNamed: "ic_umid_inverse") }

    // MARK: - icon `DriversLicense ID`
    var iconDriversLicense: UIImage? { UIImage(iconNamed: "ic_car") }
    var iconDriversLicenseInverse: UIImage? { UIImage(iconNamed: "ic_car_inverse") }

    // MARK: - icon `Voter ID`
    var iconVoter: UIImage? { UIImage(iconNamed: "ic_voter") }
    var iconVoterInverse: UIImage? { UIImage(iconNamed: "ic_voter_inverse") }

    // MARK: - icon `Philsys ID`
    var iconPhilsys: UIImage? { UIImage(iconNamed: "ic_national_id") }
    var iconPhilsysInverse: UIImage? { UIImage(iconNamed: "ic_national_id_inverse") }

    // MARK: - icon `EPhilsys ID`
    var iconEphilsys: UIImage? { UIImage(iconNamed: "ic_ephil_id") }
    var iconEphilsysInverse: UIImage? { UIImage(iconNamed: "ic_ephil_id_inverse") }

    // MARK: - icon `Social Security System (SSS) ID`
    var iconSSS: UIImage? { UIImage(iconNamed: "ic_people") }
    var iconSSSInverse: UIImage? { UIImage(iconNamed: "ic_people_inverse") }

    // MARK: - icon `SuperFAB`
    var iconSuperFABBell: UIImage? { UIImage(iconNamed: "ic_superfab_bell") }
    var iconSuperFABBuyLoad: UIImage? { UIImage(iconNamed: "ic_superfab_buy_load") }
    var iconSuperFABCard: UIImage? { UIImage(iconNamed: "ic_superfab_card") }
    var iconSuperFABCertificate: UIImage? { UIImage(iconNamed: "ic_superfab_certificate") }
    var iconSuperFABCrypto: UIImage? { UIImage(iconNamed: "ic_superfab_crypto") }
    var iconSuperFABGlobe: UIImage? { UIImage(iconNamed: "ic_superfab_globe") }
    var iconSuperFABGoRewards: UIImage? { UIImage(iconNamed: "ic_superfab_go_rewards") }
    var iconSuperFABGoSave: UIImage? { UIImage(iconNamed: "ic_superfab_go_save") }
    var iconSuperFABGotymeHeart: UIImage? { UIImage(iconNamed: "ic_superfab_gotyme_heart") }
    var iconSuperFABGotyme: UIImage? { UIImage(iconNamed: "ic_superfab_gotyme") }
    var iconSuperFABLimit: UIImage? { UIImage(iconNamed: "ic_superfab_limit") }
    var iconSuperFABLinkBank: UIImage? { UIImage(iconNamed: "ic_superfab_link_bank") }
    var iconSuperFABPayBills: UIImage? { UIImage(iconNamed: "ic_superfab_pay_bills") }
    var iconSuperFABPeople: UIImage? { UIImage(iconNamed: "ic_superfab_people") }
    var iconSuperFABSalaryAdvanced: UIImage? { UIImage(iconNamed: "ic_superfab_salary_advanced") }
    var iconSuperFABScan: UIImage? { UIImage(iconNamed: "ic_superfab_scan") }
    var iconSuperFABSendInvite: UIImage? { UIImage(iconNamed: "ic_superfab_send_invite") }
    var iconSuperFABSettings: UIImage? { UIImage(iconNamed: "ic_superfab_settings") }
    var iconSuperFABStatement: UIImage? { UIImage(iconNamed: "ic_superfab_statement") }
    var iconSuperFABStock: UIImage? { UIImage(iconNamed: "ic_superfab_stock") }
    var iconSuperFABStore: UIImage? { UIImage(iconNamed: "ic_superfab_store") }
    var iconSuperFABTimeDeposit: UIImage? { UIImage(iconNamed: "ic_superfab_time_deposit") }
    var iconSuperFABTransfer: UIImage? { UIImage(iconNamed: "ic_superfab_transfer") }
    var iconSuperFABUser: UIImage? { UIImage(iconNamed: "ic_superfab_user") }
    var iconSuperFABWithdraw: UIImage? { UIImage(iconNamed: "ic_superfab_withdraw") }
    var iconSuperFABMoreTyme: UIImage? { UIImage(iconNamed: "ic_superfab_moretyme") }

    // MARK: - icon `Info Filled`
    var iconInfoFilled: UIImage? { UIImage(iconNamed: "ic_info_filled") }
    var iconInfoFilledInverse: UIImage? { UIImage(iconNamed: "ic_info_filled_inverse") }

    // MARK: - icon `Info`
    var iconInfo: UIImage? { UIImage(iconNamed: "ic_info") }
    var iconInfoInverse: UIImage? { UIImage(iconNamed: "ic_info_inverse") }

    // MARK: - icon `Search`
    var iconSearch: UIImage? { UIImage(iconNamed: "ic_search_small") }
    var iconSearchInverse: UIImage? { UIImage(iconNamed: "ic_search_small_inverse") }

    // MARK: - icon `Bank`
    var iconBank: UIImage? { UIImage(iconNamed: "ic_bank") }
    var iconBankInverse: UIImage? { UIImage(iconNamed: "ic_bank_inverse") }

    // MARK: - icon `Bell`
    var iconBell: UIImage? { UIImage(iconNamed: "ic_bell") }
    var iconBellInverse: UIImage? { UIImage(iconNamed: "ic_bell_inverse") }

    // MARK: - icon `Card Alert`
    var iconCardAlert: UIImage? { UIImage(iconNamed: "ic_card_alert") }
    var iconCardAlertInverse: UIImage? { UIImage(iconNamed: "ic_card_alert_inverse") }

    // MARK: - icon `Copy`
    var iconCopy: UIImage? { UIImage(iconNamed: "ic_copy") }
    var iconCopyInverse: UIImage? { UIImage(iconNamed: "ic_copy_inverse") }

    // MARK: - icon `Eye Close`
    var iconEyeClose: UIImage? { UIImage(iconNamed: "ic_eye_close") }
    var iconEyeCloseInverse: UIImage? { UIImage(iconNamed: "ic_eye_close_inverse") }

    // MARK: - icon `Eye Open`
    var iconEyeOpen: UIImage? { UIImage(iconNamed: "ic_eye_open") }
    var iconEyeOpenInverse: UIImage? { UIImage(iconNamed: "ic_eye_open_inverse") }

    // MARK: - icon `Globe`
    var iconGlobe: UIImage? { UIImage(iconNamed: "ic_globe") }
    var iconGlobeInverse: UIImage? { UIImage(iconNamed: "ic_globe_inverse") }

    // MARK: - icon `GoTyme`
    var iconGoTyme: UIImage? { UIImage(iconNamed: "ic_gotyme") }
    var iconGoTymeInverse: UIImage? { UIImage(iconNamed: "ic_gotyme_inverse") }

    // MARK: - icon `Help Center`
    var iconHelpCenter: UIImage? { UIImage(iconNamed: "ic_help_center") }
    var iconHelpCenterInverse: UIImage? { UIImage(iconNamed: "ic_help_center_inverse") }

    // MARK: - icon `Limit`
    var iconLimit: UIImage? { UIImage(iconNamed: "ic_limit") }
    var iconLimitInverse: UIImage? { UIImage(iconNamed: "ic_limit_inverse") }

    // MARK: - icon `Link Bank`
    var iconLinkBank: UIImage? { UIImage(iconNamed: "ic_link_bank") }
    var iconLinkBankInverse: UIImage? { UIImage(iconNamed: "ic_link_bank_inverse") }

    // MARK: - icon `Scan`
    var iconScan: UIImage? { UIImage(iconNamed: "ic_scan") }
    var iconScanInverse: UIImage? { UIImage(iconNamed: "ic_scan_inverse") }

    // MARK: - icon `Send Invite`
    var iconSendInvite: UIImage? { UIImage(iconNamed: "ic_send_invite") }
    var iconSendInviteInverse: UIImage? { UIImage(iconNamed: "ic_send_invite_inverse") }

    // MARK: - icon `Settings`
    var iconSettings: UIImage? { UIImage(iconNamed: "ic_settings") }
    var iconSettingsInverse: UIImage? { UIImage(iconNamed: "ic_settings_inverse") }

    // MARK: - icon `Statement`
    var iconStatement: UIImage? { UIImage(iconNamed: "ic_statement") }
    var iconStatementInverse: UIImage? { UIImage(iconNamed: "ic_statement_inverse") }

    // MARK: - icon `Store`
    var iconStore: UIImage? { UIImage(iconNamed: "ic_store") }
    var iconStoreInverse: UIImage? { UIImage(iconNamed: "ic_store_inverse") }

    // MARK: - icon `User`
    var iconUser: UIImage? { UIImage(iconNamed: "ic_user") }
    var iconUserInverse: UIImage? { UIImage(iconNamed: "ic_user_inverse") }

    // MARK: - icon `Withdraw`
    var iconWithdraw: UIImage? { UIImage(iconNamed: "ic_withdraw") }
    var iconWithdrawInverse: UIImage? { UIImage(iconNamed: "ic_withdraw_inverse") }

    // MARK: - icon `Withholding Tax`
    var iconWithholdingTax: UIImage? { UIImage(iconNamed: "ic_withholding_tax") }
    var iconWithholdingTaxInverse: UIImage? { UIImage(iconNamed: "ic_withholding_tax_inverse") }

    // MARK: - icon `CardPayment`
    var iconCardPayment: UIImage? { UIImage(iconNamed: "ic_card_payment") }
    var iconCardPaymentInverse: UIImage? { UIImage(iconNamed: "ic_card_payment_inverse") }

    // MARK: - icon `BuyVas`
    var iconBuyVas: UIImage? { UIImage(iconNamed: "ic_buy_vas") }
    var iconBuyVasInverse: UIImage? { UIImage(iconNamed: "ic_buy_vas_inverse") }

    // MARK: - icon `Marketing`
    var iconMarketing: UIImage? { UIImage(iconNamed: "ic_marketing") }
    var iconMarketingInverse: UIImage? { UIImage(iconNamed: "ic_marketing_inverse") }

    // MARK: - icon `Plus`
    var iconPlus: UIImage? { UIImage(iconNamed: "ic_plus") }
    var iconPlusInverse: UIImage? { UIImage(iconNamed: "ic_plus_inverse") }

    // MARK: - icon `Minus`
    var iconMinus: UIImage? { UIImage(iconNamed: "ic_minus") }
    var iconMinusInverse: UIImage? { UIImage(iconNamed: "ic_minus_inverse") }

    // MARK: - icon `Multiply`
    var iconMultiply: UIImage? { UIImage(iconNamed: "ic_multiply") }
    var iconMultiplyInverse: UIImage? { UIImage(iconNamed: "ic_multiply_inverse") }

    // MARK: - icon `Division`
    var iconDivision: UIImage? { UIImage(iconNamed: "ic_division") }
    var iconDivisionInverse: UIImage? { UIImage(iconNamed: "ic_division_inverse") }

    // MARK: - icon `Calendar Favorite`
    var iconCalendarFavorite: UIImage? { UIImage(iconNamed: "ic_calendar_favorite") }
    var iconCalendarFavoriteInverse: UIImage? { UIImage(iconNamed: "ic_calendar_favorite_inverse") }

    // MARK: - icon `Favorite Filled`
    var iconFavoriteFilled: UIImage? { UIImage(iconNamed: "ic_favorite_filled") }

    // MARK: - icon `Instant`
    var iconInstant: UIImage? { UIImage(iconNamed: "ic_instant") }
    var iconInstantInverse: UIImage? { UIImage(iconNamed: "ic_instant_inverse") }
}
