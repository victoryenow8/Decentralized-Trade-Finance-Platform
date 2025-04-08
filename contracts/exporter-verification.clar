;; Exporter Verification Contract
;; This contract validates seller credentials and history

(define-data-var admin principal tx-sender)
(define-map exporters
  { exporter-id: (string-utf8 36) }
  {
    principal: principal,
    name: (string-utf8 100),
    country: (string-utf8 50),
    verified: bool,
    rating: uint,
    trade-count: uint
  }
)

(define-public (register-exporter (exporter-id (string-utf8 36)) (name (string-utf8 100)) (country (string-utf8 50)))
  (let ((caller tx-sender))
    (if (map-insert exporters { exporter-id: exporter-id }
                    {
                      principal: caller,
                      name: name,
                      country: country,
                      verified: false,
                      rating: u0,
                      trade-count: u0
                    })
        (ok true)
        (err u1))))

(define-public (verify-exporter (exporter-id (string-utf8 36)))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
        (match (map-get? exporters { exporter-id: exporter-id })
          exporter-data (begin
            (map-set exporters
              { exporter-id: exporter-id }
              (merge exporter-data { verified: true })
            )
            (ok true))
          (err u2))
        (err u3))))

(define-public (update-rating (exporter-id (string-utf8 36)) (new-rating uint))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
        (match (map-get? exporters { exporter-id: exporter-id })
          exporter-data (begin
            (map-set exporters
              { exporter-id: exporter-id }
              (merge exporter-data { rating: new-rating })
            )
            (ok true))
          (err u4))
        (err u5))))

(define-public (increment-trade-count (exporter-id (string-utf8 36)))
  (match (map-get? exporters { exporter-id: exporter-id })
    exporter-data (begin
      (map-set exporters
        { exporter-id: exporter-id }
        (merge exporter-data { trade-count: (+ (get trade-count exporter-data) u1) })
      )
      (ok true))
    (err u6)))

(define-read-only (get-exporter-details (exporter-id (string-utf8 36)))
  (map-get? exporters { exporter-id: exporter-id }))

(define-read-only (is-verified (exporter-id (string-utf8 36)))
  (match (map-get? exporters { exporter-id: exporter-id })
    exporter-data (get verified exporter-data)
    false))
