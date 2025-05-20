;; Allocation Contract
;; Manages distribution of inventory to retail locations

;; Define trait for inventory functions
(define-trait inventory-trait
  (
    (inventory-exists (uint uint) (response bool uint))
  )
)

(define-data-var admin principal tx-sender)

;; Allocation record structure
(define-map allocations
  { allocation-id: uint }
  {
    from-store: uint,
    to-store: uint,
    product-id: uint,
    quantity: uint,
    status: uint,  ;; 0: pending, 1: in-transit, 2: completed, 3: canceled
    created-at: uint,
    updated-at: uint
  }
)

(define-data-var next-allocation-id uint u1)

;; Read-only function to get the next allocation ID
(define-read-only (get-next-allocation-id)
  (var-get next-allocation-id)
)

;; Read-only function to get allocation details
(define-read-only (get-allocation (allocation-id uint))
  (map-get? allocations { allocation-id: allocation-id })
)

;; Create a new allocation - restricted to admin
(define-public (create-allocation (from-store uint) (to-store uint) (product-id uint) (quantity uint))
  (if (is-eq tx-sender (var-get admin))
    (let ((new-id (var-get next-allocation-id)))
      (begin
        (map-set allocations
          { allocation-id: new-id }
          {
            from-store: from-store,
            to-store: to-store,
            product-id: product-id,
            quantity: quantity,
            status: u0,  ;; pending
            created-at: block-height,
            updated-at: block-height
          }
        )
        (var-set next-allocation-id (+ new-id u1))
        (ok new-id)
      )
    )
    (err u1)  ;; Error: not authorized
  )
)

;; Update allocation status - restricted to admin
(define-public (update-allocation-status (allocation-id uint) (new-status uint))
  (if (is-eq tx-sender (var-get admin))
    (let ((current-allocation (unwrap! (get-allocation allocation-id) (err u3))))
      (begin
        (map-set allocations
          { allocation-id: allocation-id }
          (merge current-allocation
                {
                  status: new-status,
                  updated-at: block-height
                })
        )
        (ok true)
      )
    )
    (err u1)  ;; Error: not authorized
  )
)

;; Complete allocation and update inventory - restricted to admin
(define-public (complete-allocation (allocation-id uint))
  (if (is-eq tx-sender (var-get admin))
    (let ((current-allocation (unwrap! (get-allocation allocation-id) (err u3))))
      (if (is-eq (get status current-allocation) u1)  ;; only complete if in-transit
        (begin
          ;; Update allocation status
          (map-set allocations
            { allocation-id: allocation-id }
            (merge current-allocation
                  {
                    status: u2,  ;; completed
                    updated-at: block-height
                  })
          )
          ;; In a full implementation, this would also call inventory-tracking contract
          ;; to update the source and destination inventory levels
          (ok true)
        )
        (err u2)  ;; Error: allocation not in in-transit status
      )
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
