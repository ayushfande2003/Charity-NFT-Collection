;; Charity NFT Contract
;; Owner mints NFTs and tracks donations
;; Donations forwarded to the charity wallet (owner's wallet)

;; Replace with your actual wallet address
(define-constant CONTRACT_OWNER 'ST30BWDC1MXWJJHFN0MEFH457R7XKCVTB9H6RH9Q1)

(define-data-var total-supply uint u0)
(define-data-var token-id-counter uint u0)

(define-map token-owner
  { token-id: uint }
  { owner: principal }
)

(define-map token-uri
  { token-id: uint }
  { uri: (string-ascii 256) }
)

(define-map token-donation
  { token-id: uint }
  { amount: uint }
)

(define-public (mint (recipient principal) (uri (string-ascii 256)) (donation uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err u100)) ;; Only owner can mint
    (var-set total-supply (+ (var-get total-supply) u1))
    (var-set token-id-counter (+ (var-get token-id-counter) u1))
    (let ((new-id (var-get token-id-counter)))
      (map-set token-owner { token-id: new-id } { owner: recipient })
      (map-set token-uri { token-id: new-id } { uri: uri })
      (map-set token-donation { token-id: new-id } { amount: donation })
      (ok new-id)
    )
  )
)

(define-read-only (get-owner (token-id uint))
  (match (map-get? token-owner { token-id: token-id })
    owner-data (ok (get owner owner-data))
    (err u404)
  )
)

(define-read-only (get-token-uri (token-id uint))
  (match (map-get? token-uri { token-id: token-id })
    uri-data (ok (get uri uri-data))
    (err u404)
  )
)

(define-read-only (get-donation (token-id uint))
  (match (map-get? token-donation { token-id: token-id })
    donation-data (ok (get amount donation-data))
    (err u404)
  )
)

(define-public (transfer (token-id uint) (new-owner principal))
  (match (map-get? token-owner { token-id: token-id })
    owner-data
      (if (is-eq (get owner owner-data) tx-sender)
        (begin
          (map-set token-owner { token-id: token-id } { owner: new-owner })
          (ok true)
        )
        (err u403)
      )
    (err u404)
  )
)
