;; Fulfillment Contract
;; Tracks order processing and fulfillment

;; Define trait for inventory functions
(define-trait inventory-trait
  (
    (inventory-exists (uint uint) (response bool uint))
  )
)

(define-data-var admin principal tx-sender)

;; Order status: 0: created, 1: processing, 2: ready for pickup, 3: shipped, 4: delivered, 5: canceled
(define-map orders
  { order-id: uint }
  {
    customer-id: (string-ascii 50),
    store-id: uint,
    total-amount: uint,
    status: uint,
    created-at: uint,
    updated-at: uint
  }
)

;; Order items map
(define-map order-items
  { order-id: uint, item-index: uint }
  {
    product-id: uint,
    quantity: uint,
    price: uint
  }
)

(define-map order-item-count
  { order-id: uint }
  { count: uint }
)

(define-data-var next-order-id uint u1)

;; Read-only function to get the next order ID
(define-read-only (get-next-order-id)
  (var-get next-order-id)
)

;; Read-only function to get order details
(define-read-only (get-order (order-id uint))
  (map-get? orders { order-id: order-id })
)

;; Read-only function to get order item
(define-read-only (get-order-item (order-id uint) (item-index uint))
  (map-get? order-items { order-id: order-id, item-index: item-index })
)

;; Read-only function to get order item count
(define-read-only (get-order-item-count (order-id uint))
  (default-to { count: u0 } (map-get? order-item-count { order-id: order-id }))
)

;; Create a new order - can be called by anyone
(define-public (create-order (customer-id (string-ascii 50)) (store-id uint) (total-amount uint))
  (let ((new-id (var-get next-order-id)))
    (begin
      (map-set orders
        { order-id: new-id }
        {
          customer-id: customer-id,
          store-id: store-id,
          total-amount: total-amount,
          status: u0,  ;; created
          created-at: block-height,
          updated-at: block-height
        }
      )
      (map-set order-item-count
        { order-id: new-id }
        { count: u0 }
      )
      (var-set next-order-id (+ new-id u1))
      (ok new-id)
    )
  )
)

;; Add an item to an order
(define-public (add-order-item (order-id uint) (product-id uint) (quantity uint) (price uint))
  (let ((current-order (unwrap! (get-order order-id) (err u3)))
        (current-count (get count (get-order-item-count order-id))))
    (if (is-eq (get status current-order) u0)  ;; only if order is in created status
      (begin
        (map-set order-items
          { order-id: order-id, item-index: current-count }
          {
            product-id: product-id,
            quantity: quantity,
            price: price
          }
        )
        (map-set order-item-count
          { order-id: order-id }
          { count: (+ current-count u1) }
        )
        (ok true)
      )
      (err u2)  ;; Error: order not in created status
    )
  )
)

;; Update order status - restricted to admin
(define-public (update-order-status (order-id uint) (new-status uint))
  (if (is-eq tx-sender (var-get admin))
    (let ((current-order (unwrap! (get-order order-id) (err u3))))
      (begin
        (map-set orders
          { order-id: order-id }
          (merge current-order
                {
                  status: new-status,
                  updated-at: block-height
                })
        )
        ;; In a full implementation, this would also call inventory-tracking contract
        ;; to update inventory levels when necessary
        (ok true)
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
