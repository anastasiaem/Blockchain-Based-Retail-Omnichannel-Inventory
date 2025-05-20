;; Inventory Tracking Contract
;; Monitors stock levels across retail locations

;; Define traits for store and product verification
(define-trait store-trait
  (
    (store-exists (uint) (response bool uint))
  )
)

(define-trait product-trait
  (
    (product-exists (uint) (response bool uint))
  )
)

(define-data-var admin principal tx-sender)

;; Inventory map: store id -> product id -> quantity
(define-map inventory
  { store-id: uint, product-id: uint }
  { quantity: uint, last-updated: uint }
)

;; Read-only function to get inventory for a product at a store
(define-read-only (get-inventory (store-id uint) (product-id uint))
  (map-get? inventory { store-id: store-id, product-id: product-id })
)

;; Read-only function to check if inventory exists
(define-read-only (inventory-exists (store-id uint) (product-id uint))
  (is-some (map-get? inventory { store-id: store-id, product-id: product-id }))
)

;; Add inventory - restricted to admin
(define-public (add-inventory (store-id uint) (product-id uint) (quantity uint))
  (if (is-eq tx-sender (var-get admin))
    (let ((current-inventory (get-inventory store-id product-id)))
      (begin
        (map-set inventory
          { store-id: store-id, product-id: product-id }
          {
            quantity: (if (is-some current-inventory)
                        (+ quantity (get quantity (unwrap! current-inventory (err u4))))
                        quantity),
            last-updated: block-height
          }
        )
        (ok true)
      )
    )
    (err u1)  ;; Error: not authorized
  )
)

;; Remove inventory - restricted to admin
(define-public (remove-inventory (store-id uint) (product-id uint) (quantity uint))
  (if (is-eq tx-sender (var-get admin))
    (let ((current-inventory (unwrap! (get-inventory store-id product-id) (err u3))))
      (if (>= (get quantity current-inventory) quantity)
        (begin
          (map-set inventory
            { store-id: store-id, product-id: product-id }
            {
              quantity: (- (get quantity current-inventory) quantity),
              last-updated: block-height
            }
          )
          (ok true)
        )
        (err u2)  ;; Error: insufficient inventory
      )
    )
    (err u1)  ;; Error: not authorized
  )
)

;; Set exact inventory - restricted to admin
(define-public (set-inventory (store-id uint) (product-id uint) (quantity uint))
  (if (is-eq tx-sender (var-get admin))
    (begin
      (map-set inventory
        { store-id: store-id, product-id: product-id }
        {
          quantity: quantity,
          last-updated: block-height
        }
      )
      (ok true)
    )
    (err u1)  ;; Error: not authorized
  )
)

;; Update admin
(define-public (set-admin (new-admin principal))
  (if (is-eq tx-sender (var-get admin))
    (begin
      (var-set admin new-admin)
      (ok true)
    )
    (err u1)  ;; Error: not authorized
  )
)
