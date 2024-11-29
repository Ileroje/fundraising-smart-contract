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
(define-constant err-donation-id-mismatch (err u107)) ;; Error for donor mismatch

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

(define-public (increase-donation (donation-id uint) (additional-amount uint))
    (begin
        ;; Ensure donation is a valid amount
        (asserts! (is-valid-donation-amount additional-amount) err-invalid-amount)
        ;; Validate the donation ID and get the existing donation
        (let ((donation (unwrap-panic (map-get? donation-records donation-id))))
            ;; Ensure the caller is the donor
            (asserts! (is-eq tx-sender (get donor donation)) err-donation-id-mismatch)
            ;; Increase the donation amount
            (let ((new-amount (+ (get amount donation) additional-amount)))
                ;; Update the donation record with the new amount
                (map-set donation-records donation-id {amount: new-amount, donor: tx-sender, refunded: false})
                ;; Update the total donations
                (var-set total-donations (+ (var-get total-donations) additional-amount))
                ;; Check if the new total donations exceed the target
                (asserts! (< (var-get total-donations) (var-get donation-target)) err-donation-exceeds-target)
                ;; Return the new donation amount
                (ok new-amount)))))

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

(define-public (get-total-donations)
    (ok (var-get total-donations)))

(define-public (get-donation-target)
    (ok (var-get donation-target)))

(define-public (get-last-donation-id)
    (ok (var-get last-donation-id)))

(define-public (request-refund (donation-id uint))
    (begin
        ;; Validate the donation ID
        (asserts! (is-valid-donation-id donation-id) err-invalid-donation-id)
        ;; Get the donation record
        (let ((donation (unwrap-panic (map-get? donation-records donation-id))))
            ;; Ensure the caller is the donor
            (asserts! (is-eq tx-sender (get donor donation)) err-owner-only)
            ;; Check if the donation has been refunded already
            (asserts! (is-eq (get refunded donation) false) err-refund-not-allowed)
            ;; Ensure the donation hasn't contributed to the target
            (asserts! (has-reached-target) err-refund-not-allowed)
            ;; Decrease total donations
            (var-set total-donations (- (var-get total-donations) (get amount donation)))
            ;; Mark the donation as refunded
            (map-set donation-records donation-id {amount: (get amount donation), donor: (get donor donation), refunded: true})
            ;; Return the refunded amount
            (ok (get amount donation)))))

;; Read-Only Functions
(define-read-only (get-donations-for-donor (donor principal))
    (let ((last-id (var-get last-donation-id)))
        (ok (filter get-donation-matches 
            (list last-id)))))

(define-private (get-donation-matches (donation-id uint))
    (match (map-get? donation-records donation-id)
        donation-record (is-eq (get donor donation-record) tx-sender)
        false))

(define-read-only (get-total-donations-for-donor (donor principal))
(let ((last-id (var-get last-donation-id))
      (donor-total u0))
    (fold get-donor-donation-total
        (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9)  ;; Supports first 10 donations for demonstration
        donor-total)))

(define-private (get-donor-donation-total (donation-id uint) (running-total uint))
(match (map-get? donation-records donation-id)
    donation-record
    (if (is-eq (get donor donation-record) tx-sender)
        (+ running-total (get amount donation-record))
        running-total)
    running-total))

;; Contract initialization
(begin
    ;; Initialize the contract's last donation ID and total donations
    (var-set last-donation-id u0)
    (var-set total-donations u0))
