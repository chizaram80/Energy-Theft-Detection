;; Energy Grid Monitoring & Theft Prevention System Smart Contract 
;; A comprehensive blockchain-based solution for monitoring electricity consumption,
;; detecting energy theft patterns through anomaly analysis, and implementing
;; automated penalty enforcement across distributed smart grid networks.

;; CORE SYSTEM CONSTANTS

;; Administrative Control
(define-constant system-administrator-principal tx-sender)

;; System Error Definitions
(define-constant ERROR-ACCESS-DENIED (err u100))
(define-constant ERROR-ENTITY-NOT-FOUND (err u101))
(define-constant ERROR-DUPLICATE-REGISTRATION (err u102))
(define-constant ERROR-INVALID-INPUT-DATA (err u103))
(define-constant ERROR-INSUFFICIENT-BALANCE (err u104))
(define-constant ERROR-OPERATION-NOT-ALLOWED (err u105))
(define-constant ERROR-METER-DISABLED (err u106))
(define-constant ERROR-INCIDENT-ALREADY-RESOLVED (err u107))
(define-constant ERROR-INVALID-ADDRESS (err u108))
(define-constant ERROR-UNAUTHORIZED-METER-ACCESS (err u109))

;; Energy Consumption Anomaly Detection Parameters
(define-constant low-risk-consumption-threshold u150)      ;; 50% above baseline
(define-constant medium-risk-consumption-threshold u200)   ;; 100% above baseline  
(define-constant high-risk-consumption-threshold u300)     ;; 200% above baseline

;; Financial Penalty Structure (in microSTX)
(define-constant low-severity-penalty-amount u1000000)     ;; 1 STX
(define-constant medium-severity-penalty-amount u5000000)  ;; 5 STX
(define-constant high-severity-penalty-amount u10000000)   ;; 10 STX

;; System Operational Limits
(define-constant max-installation-address-length u100)
(define-constant min-valid-consumption-reading u1)
(define-constant max-smart-meter-id u999999)
(define-constant max-security-incident-id u999999)

;; GLOBAL STATE MANAGEMENT

(define-data-var total-active-smart-meters uint u0)
(define-data-var total-penalty-fees-collected uint u0)
(define-data-var contract-treasury-funds uint u0)
(define-data-var next-smart-meter-registration-id uint u1)
(define-data-var next-security-incident-tracking-id uint u1)

;; DATA STORAGE STRUCTURES

;; Smart Meter Device Registry
(define-map energy-meter-device-registry
  { smart-meter-device-id: uint }
  {
    property-owner-wallet-address: principal,
    physical-installation-address: (string-ascii 100),
    baseline-energy-consumption-kwh: uint,
    most-recent-consumption-reading: uint,
    last-data-update-block-number: uint,
    total-consumption-readings-count: uint,
    device-operational-status: bool,
    suspicious-activity-detection-count: uint
  }
)

;; Historical Energy Consumption Records
(define-map historical-energy-consumption-logs
  { smart-meter-device-id: uint, consumption-reading-sequence: uint }
  {
    energy-consumption-kwh-value: uint,
    data-collection-timestamp: uint,
    blockchain-recording-block: uint,
    consumption-anomaly-risk-score: uint
  }
)

;; Energy Theft Security Incidents
(define-map energy-theft-incident-records
  { security-incident-tracking-id: uint }
  {
    involved-smart-meter-device-id: uint,
    incident-detection-block-height: uint,
    theft-risk-severity-classification: (string-ascii 10),
    financial-penalty-assessment: uint,
    incident-resolution-completed: bool,
    resolution-completion-block: (optional uint)
  }
)

;; Authorized System Personnel
(define-map authorized-system-operators
  { operator-wallet-address: principal }
  { system-access-authorization: bool }
)

;; Property Owner Account Management
(define-map property-owner-account-registry
  { property-owner-wallet-address: principal }
  { owned-smart-meters-total: uint }
)

;; INPUT VALIDATION FUNCTIONS

;; Validate wallet address format
(define-private (is-valid-wallet-address (wallet-address principal))
  (not (is-eq wallet-address 'SP000000000000000000002Q6VF78))
)

;; Validate smart meter device identifier
(define-private (is-valid-smart-meter-id (meter-device-id uint))
  (and 
    (> meter-device-id u0)
    (<= meter-device-id max-smart-meter-id)
  )
)

;; Validate security incident identifier
(define-private (is-valid-incident-tracking-id (incident-tracking-id uint))
  (and 
    (> incident-tracking-id u0)
    (<= incident-tracking-id max-security-incident-id)
  )
)

;; Validate energy consumption reading
(define-private (is-valid-consumption-reading (consumption-kwh uint))
  (and 
    (>= consumption-kwh min-valid-consumption-reading)
    (<= consumption-kwh u999999999)
  )
)

;; Validate installation address format
(define-private (is-valid-installation-address (installation-address (string-ascii 100)))
  (and 
    (> (len installation-address) u0)
    (<= (len installation-address) max-installation-address-length)
  )
)

;; AUTHORIZATION & SECURITY FUNCTIONS

;; Verify system administrator privileges
(define-private (has-administrator-privileges)
  (is-eq tx-sender system-administrator-principal)
)

;; Verify authorized operator status
(define-private (has-operator-authorization (operator-address principal))
  (default-to false 
    (get system-access-authorization 
      (map-get? authorized-system-operators { operator-wallet-address: operator-address })
    )
  )
)

;; Check smart meter ownership
(define-private (is-meter-owner (meter-device-id uint) (claiming-owner-address principal))
  (match (map-get? energy-meter-device-registry { smart-meter-device-id: meter-device-id })
    meter-registration-data (is-eq (get property-owner-wallet-address meter-registration-data) claiming-owner-address)
    false
  )
)

;; Verify smart meter exists in registry
(define-private (smart-meter-is-registered (meter-device-id uint))
  (is-some (map-get? energy-meter-device-registry { smart-meter-device-id: meter-device-id }))
)

;; Verify security incident exists
(define-private (security-incident-exists (incident-tracking-id uint))
  (is-some (map-get? energy-theft-incident-records { security-incident-tracking-id: incident-tracking-id }))
)

;; ANOMALY DETECTION & ANALYSIS

;; Calculate consumption anomaly risk score
(define-private (calculate-consumption-anomaly-score (baseline-consumption-kwh uint) (current-consumption-kwh uint))
  (if (is-eq baseline-consumption-kwh u0)
    u100 ;; Neutral score for new installations
    (/ (* current-consumption-kwh u100) baseline-consumption-kwh)
  )
)

;; Classify energy theft risk severity
(define-private (determine-theft-risk-severity (anomaly-risk-score uint))
  (if (>= anomaly-risk-score high-risk-consumption-threshold)
    "high"
    (if (>= anomaly-risk-score medium-risk-consumption-threshold)
      "medium"
      (if (>= anomaly-risk-score low-risk-consumption-threshold)
        "low"
        "normal"
      )
    )
  )
)

;; Calculate financial penalty based on severity
(define-private (determine-penalty-amount (theft-risk-severity (string-ascii 10)))
  (if (is-eq theft-risk-severity "high")
    high-severity-penalty-amount
    (if (is-eq theft-risk-severity "medium")
      medium-severity-penalty-amount
      (if (is-eq theft-risk-severity "low")
        low-severity-penalty-amount
        u0
      )
    )
  )
)

;; SYSTEM OPERATOR MANAGEMENT

;; Grant system operator authorization
(define-public (authorize-system-operator (operator-wallet-address principal))
  (begin
    (asserts! (has-administrator-privileges) ERROR-ACCESS-DENIED)
    (asserts! (is-valid-wallet-address operator-wallet-address) ERROR-INVALID-ADDRESS)
    (asserts! (not (is-eq operator-wallet-address system-administrator-principal)) ERROR-INVALID-INPUT-DATA)
    
    (map-set authorized-system-operators 
      { operator-wallet-address: operator-wallet-address } 
      { system-access-authorization: true }
    )
    (ok true)
  )
)

;; Revoke system operator authorization
(define-public (revoke-system-operator-authorization (operator-wallet-address principal))
  (begin
    (asserts! (has-administrator-privileges) ERROR-ACCESS-DENIED)
    (asserts! (is-valid-wallet-address operator-wallet-address) ERROR-INVALID-ADDRESS)
    
    (map-set authorized-system-operators 
      { operator-wallet-address: operator-wallet-address } 
      { system-access-authorization: false }
    )
    (ok true)
  )
)

;; SMART METER REGISTRATION & MANAGEMENT

;; Register new smart meter installation
(define-public (register-new-smart-meter (property-owner-address principal) (installation-location (string-ascii 100)))
  (let (
    (validated-owner-address property-owner-address)
    (validated-installation-location installation-location)
    (new-meter-registration-id (var-get next-smart-meter-registration-id))
    (current-owner-account-data (default-to { owned-smart-meters-total: u0 } 
      (map-get? property-owner-account-registry { property-owner-wallet-address: validated-owner-address })
    ))
  )
    (asserts! (has-administrator-privileges) ERROR-ACCESS-DENIED)
    (asserts! (is-valid-wallet-address validated-owner-address) ERROR-INVALID-ADDRESS)
    (asserts! (is-valid-installation-address validated-installation-location) ERROR-INVALID-INPUT-DATA)
    
    ;; Create smart meter registry entry
    (map-set energy-meter-device-registry
      { smart-meter-device-id: new-meter-registration-id }
      {
        property-owner-wallet-address: validated-owner-address,
        physical-installation-address: validated-installation-location,
        baseline-energy-consumption-kwh: u0,
        most-recent-consumption-reading: u0,
        last-data-update-block-number: block-height,
        total-consumption-readings-count: u0,
        device-operational-status: true,
        suspicious-activity-detection-count: u0
      }
    )
    
    ;; Update property owner account
    (map-set property-owner-account-registry
      { property-owner-wallet-address: validated-owner-address }
      { owned-smart-meters-total: (+ (get owned-smart-meters-total current-owner-account-data) u1) }
    )
    
    ;; Update system state variables
    (var-set next-smart-meter-registration-id (+ new-meter-registration-id u1))
    (var-set total-active-smart-meters (+ (var-get total-active-smart-meters) u1))
    
    (ok new-meter-registration-id)
  )
)

;; Disable smart meter operations
(define-public (disable-smart-meter-device (meter-device-id uint))
  (let (
    (validated-meter-id meter-device-id)
    (meter-registration-data (unwrap! (map-get? energy-meter-device-registry { smart-meter-device-id: validated-meter-id }) ERROR-ENTITY-NOT-FOUND))
  )
    (asserts! (is-valid-smart-meter-id validated-meter-id) ERROR-INVALID-INPUT-DATA)
    (asserts! (or (has-administrator-privileges) (is-meter-owner validated-meter-id tx-sender)) ERROR-ACCESS-DENIED)
    
    (map-set energy-meter-device-registry
      { smart-meter-device-id: validated-meter-id }
      (merge meter-registration-data { device-operational-status: false })
    )
    
    (ok true)
  )
)

;; Enable smart meter operations
(define-public (enable-smart-meter-device (meter-device-id uint))
  (let (
    (validated-meter-id meter-device-id)
    (meter-registration-data (unwrap! (map-get? energy-meter-device-registry { smart-meter-device-id: validated-meter-id }) ERROR-ENTITY-NOT-FOUND))
  )
    (asserts! (has-administrator-privileges) ERROR-ACCESS-DENIED)
    (asserts! (is-valid-smart-meter-id validated-meter-id) ERROR-INVALID-INPUT-DATA)
    
    (map-set energy-meter-device-registry
      { smart-meter-device-id: validated-meter-id }
      (merge meter-registration-data { device-operational-status: true })
    )
    
    (ok true)
  )
)

;; ENERGY CONSUMPTION MONITORING

;; Process energy consumption data and detect anomalies
(define-public (process-energy-consumption-data (meter-device-id uint) (consumption-reading-kwh uint))
  (let (
    (validated-meter-id meter-device-id)
    (validated-consumption-value consumption-reading-kwh)
    (meter-registration-data (unwrap! (map-get? energy-meter-device-registry { smart-meter-device-id: validated-meter-id }) ERROR-ENTITY-NOT-FOUND))
    (baseline-consumption-value (get baseline-energy-consumption-kwh meter-registration-data))
    (calculated-anomaly-score (calculate-consumption-anomaly-score baseline-consumption-value validated-consumption-value))
    (theft-risk-classification (determine-theft-risk-severity calculated-anomaly-score))
    (new-reading-sequence-number (+ (get total-consumption-readings-count meter-registration-data) u1))
  )
    (asserts! (or (has-administrator-privileges) (has-operator-authorization tx-sender)) ERROR-ACCESS-DENIED)
    (asserts! (is-valid-smart-meter-id validated-meter-id) ERROR-INVALID-INPUT-DATA)
    (asserts! (is-valid-consumption-reading validated-consumption-value) ERROR-INVALID-INPUT-DATA)
    (asserts! (get device-operational-status meter-registration-data) ERROR-METER-DISABLED)
    
    ;; Store consumption data in historical logs
    (map-set historical-energy-consumption-logs
      { smart-meter-device-id: validated-meter-id, consumption-reading-sequence: new-reading-sequence-number }
      {
        energy-consumption-kwh-value: validated-consumption-value,
        data-collection-timestamp: block-height,
        blockchain-recording-block: block-height,
        consumption-anomaly-risk-score: calculated-anomaly-score
      }
    )
    
    ;; Update smart meter registry with latest data
    (map-set energy-meter-device-registry
      { smart-meter-device-id: validated-meter-id }
      (merge meter-registration-data {
        most-recent-consumption-reading: validated-consumption-value,
        last-data-update-block-number: block-height,
        total-consumption-readings-count: new-reading-sequence-number,
        baseline-energy-consumption-kwh: (if (is-eq baseline-consumption-value u0) validated-consumption-value baseline-consumption-value),
        suspicious-activity-detection-count: (if (not (is-eq theft-risk-classification "normal"))
                                                (+ (get suspicious-activity-detection-count meter-registration-data) u1)
                                                (get suspicious-activity-detection-count meter-registration-data))
      })
    )
    
    ;; Handle suspicious activity detection
    (if (not (is-eq theft-risk-classification "normal"))
      (let (
        (new-incident-tracking-id (var-get next-security-incident-tracking-id))
        (calculated-penalty-amount (determine-penalty-amount theft-risk-classification))
      )
        (map-set energy-theft-incident-records
          { security-incident-tracking-id: new-incident-tracking-id }
          {
            involved-smart-meter-device-id: validated-meter-id,
            incident-detection-block-height: block-height,
            theft-risk-severity-classification: theft-risk-classification,
            financial-penalty-assessment: calculated-penalty-amount,
            incident-resolution-completed: false,
            resolution-completion-block: none
          }
        )
        (var-set next-security-incident-tracking-id (+ new-incident-tracking-id u1))
        (var-set total-penalty-fees-collected (+ (var-get total-penalty-fees-collected) calculated-penalty-amount))
        (ok { 
          consumption-data-processed: true, 
          suspicious-activity-detected: true, 
          incident-tracking-id: new-incident-tracking-id, 
          risk-severity-level: theft-risk-classification 
        })
      )
      (ok { 
        consumption-data-processed: true, 
        suspicious-activity-detected: false, 
        incident-tracking-id: u0, 
        risk-severity-level: "normal" 
      })
    )
  )
)

;; SECURITY INCIDENT RESOLUTION

;; Process security incident resolution and penalty payment
(define-public (resolve-energy-theft-incident (incident-tracking-id uint))
  (let (
    (validated-incident-id incident-tracking-id)
    (incident-record_data (unwrap! (map-get? energy-theft-incident-records { security-incident-tracking-id: validated-incident-id }) ERROR-ENTITY-NOT-FOUND))
    (required-penalty-payment (get financial-penalty-assessment incident-record_data))
  )
    (asserts! (is-valid-incident-tracking-id validated-incident-id) ERROR-INVALID-INPUT-DATA)
    (asserts! (not (get incident-resolution-completed incident-record_data)) ERROR-INCIDENT-ALREADY-RESOLVED)
    
    ;; Process penalty payment transfer
    (try! (stx-transfer? required-penalty-payment tx-sender (as-contract tx-sender)))
    
    ;; Mark incident as resolved
    (map-set energy-theft-incident-records
      { security-incident-tracking-id: validated-incident-id }
      (merge incident-record_data {
        incident-resolution-completed: true,
        resolution-completion-block: (some block-height)
      })
    )
    
    ;; Update contract treasury
    (var-set contract-treasury-funds (+ (var-get contract-treasury-funds) required-penalty-payment))
    
    (ok true)
  )
)

;; TREASURY MANAGEMENT

;; Withdraw funds from contract treasury
(define-public (withdraw-treasury-funds (withdrawal-amount-microstx uint))
  (begin
    (asserts! (has-administrator-privileges) ERROR-ACCESS-DENIED)
    (asserts! (> withdrawal-amount-microstx u0) ERROR-INVALID-INPUT-DATA)
    (asserts! (<= withdrawal-amount-microstx (var-get contract-treasury-funds)) ERROR-INSUFFICIENT-BALANCE)
    
    (try! (as-contract (stx-transfer? withdrawal-amount-microstx tx-sender system-administrator-principal)))
    (var-set contract-treasury-funds (- (var-get contract-treasury-funds) withdrawal-amount-microstx))
    
    (ok true)
  )
)

;; DATA QUERY FUNCTIONS

;; Retrieve smart meter device information
(define-read-only (get-smart-meter-details (meter-device-id uint))
  (if (is-valid-smart-meter-id meter-device-id)
    (map-get? energy-meter-device-registry { smart-meter-device-id: meter-device-id })
    none
  )
)

;; Retrieve historical consumption data
(define-read-only (get-consumption-history-record (meter-device-id uint) (reading-sequence-number uint))
  (if (and (is-valid-smart-meter-id meter-device-id) (> reading-sequence-number u0))
    (map-get? historical-energy-consumption-logs { smart-meter-device-id: meter-device-id, consumption-reading-sequence: reading-sequence-number })
    none
  )
)

;; Retrieve security incident details
(define-read-only (get-security-incident-information (incident-tracking-id uint))
  (if (is-valid-incident-tracking-id incident-tracking-id)
    (map-get? energy-theft-incident-records { security-incident-tracking-id: incident-tracking-id })
    none
  )
)

;; Retrieve comprehensive system statistics
(define-read-only (get-system-overview-statistics)
  {
    total-smart-meters-registered: (var-get total-active-smart-meters),
    total-penalty-fees-assessed: (var-get total-penalty-fees-collected),
    current-treasury-balance: (var-get contract-treasury-funds),
    next-meter-registration-id: (var-get next-smart-meter-registration-id),
    next-incident-tracking-id: (var-get next-security-incident-tracking-id)
  }
)

;; Check system operator authorization status
(define-read-only (check-operator-authorization-status (operator-address principal))
  (if (is-valid-wallet-address operator-address)
    (has-operator-authorization operator-address)
    false
  )
)

;; Get property owner's smart meter count
(define-read-only (get-property-owner-meter-count (owner-address principal))
  (if (is-valid-wallet-address owner-address)
    (default-to u0 (get owned-smart-meters-total (map-get? property-owner-account-registry { property-owner-wallet-address: owner-address })))
    u0
  )
)

;; Calculate current anomaly score for a meter
(define-read-only (get-current-anomaly-risk-score (meter-device-id uint))
  (if (is-valid-smart-meter-id meter-device-id)
    (match (map-get? energy-meter-device-registry { smart-meter-device-id: meter-device-id })
      meter-data (calculate-consumption-anomaly-score 
                   (get baseline-energy-consumption-kwh meter-data) 
                   (get most-recent-consumption-reading meter-data))
      u0
    )
    u0
  )
)

;; Verify smart meter ownership
(define-read-only (verify-smart-meter-ownership (meter-device-id uint) (claiming-owner-address principal))
  (if (and (is-valid-smart-meter-id meter-device-id) (is-valid-wallet-address claiming-owner-address))
    (is-meter-owner meter-device-id claiming-owner-address)
    false
  )
)