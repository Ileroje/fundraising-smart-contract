;; Charitable Donations and Impact Tracking Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-amount (err u101))
(define-constant err-donation-not-found (err u102))
(define-constant err-donation-exceeds-target (err u103))
(define-constant err-invalid-target (err u104))
(define-constant err-invalid-donation-id (err u105))
(define-constant err-refund-not-allowed (err u106)) ;; Error when refund is not allowed

;; Data Variables
(define-data-var last-donation-id uint u0)
(define-data-var total-donations uint u0)  ;; Track total donations collected
(define-data-var donation-target uint u1000)  ;; Set donation target (in the smallest unit of currency)

;; Maps
(define-map donation-records uint {amount: uint, donor: principal, refunded: bool})  ;; Track donations with ID, amount, donor, and refund status

;; Private Functions
(define-private (is-valid-donation-amount (amount uint))
    (>= amount u1))  ;; Ensure donation is a positive amount

(define-private (is-valid-target (target uint))
    (and
        (> target u0)
        (>= target (var-get total-donations))))

(define-private (is-valid-donation-id (donation-id uint))
    (<= donation-id (var-get last-donation-id)))

(define-private (get-donation (donation-id uint))
    (unwrap-panic (map-get? donation-records donation-id)))

(define-private (has-reached-target)
    (< (var-get total-donations) (var-get donation-target)))

;; Public Functions
(define-public (donate (amount uint))
    (begin
        ;; Ensure donation is a valid amount
        (asserts! (is-valid-donation-amount amount) err-invalid-amount)
        ;; Increment the donation ID
        (let ((donation-id (+ (var-get last-donation-id) u1)))
            ;; Store the donation record with refund flag set to false
            (map-set donation-records donation-id {amount: amount, donor: tx-sender, refunded: false})
            ;; Update the total donations collected
            (var-set total-donations (+ (var-get total-donations) amount))
            ;; Update the last donation ID
            (var-set last-donation-id donation-id)

            ;; Check if donation goal has been met
            (asserts! (< (var-get total-donations) (var-get donation-target)) err-donation-exceeds-target)
            ;; Return the donation ID
            (ok donation-id))))

(define-public (set-donation-target (target uint))
    (begin
        ;; Only the contract owner can set the donation target
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        ;; Validate the new target
        (asserts! (is-valid-target target) err-invalid-target)
        ;; Set the new target
        (var-set donation-target target)
        (ok target)))

(define-public (get-donation-details (donation-id uint))
    (begin
        ;; Validate the donation ID
        (asserts! (is-valid-donation-id donation-id) err-invalid-donation-id)
        ;; Return the donation details
        (match (map-get? donation-records donation-id)
            donation-record (ok donation-record)
            err-donation-not-found)))

