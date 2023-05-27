Chắc chắn! Đây là một ví dụ về hợp đồng thông minh trong Plutus có thể chuyển tiền đến một địa chỉ ví nhất định sau 10 năm:


```
-- Define the smart contract
{-# INLINABLE tenYearTransfer #-}
tenYearTransfer :: Wallet -> Value -> Contract () Schema Text ()
tenYearTransfer receiver amount = do
    let deadline = slotToPOSIXTime (Slot 10 * 365 * 24 * 60 * 60)
    now <- currentTime
    if now < deadline
        then logInfo @String "Transfer can only be made after 10 years"
        else do
            let tx = mustPayToPubKey receiver amount
            void $ submitTxConstraints (typedValidator @MyRedeemer) tx

-- Define the validator
{-# INLINABLE validate #-}
validate :: MyRedeemer -> () -> ScriptContext -> Bool
validate _ _ ctx =
    let
        info :: TxInfo
        info = scriptContextTxInfo ctx

        txOutValue :: Value
        txOutValue = txInfoOutValue info

        txOut :: TxOut
        txOut = case getContinuingOutputs ctx of
            [o] -> o
            _   -> traceError "expected exactly one output"

        deadline :: POSIXTime
        deadline = slotToPOSIXTime (Slot 10 * 365 * 24 * 60 * 60)

        -- Check that the transaction is being made after the deadline
        deadlinePassed :: Bool
        deadlinePassed = contains (from $ deadline) $ txInfoValidRange info

        -- Check that the output is being sent to the specified address
        outputToRecipient :: Bool
        outputToRecipient = txOutAddress txOut == paymentPubKeyHash (scriptContextTxOutCtx ctx) (scriptContextTxOutInfo ctx)

        -- Check that the output value is equal to the specified amount
        outputHasCorrectAmount :: Bool
        outputHasCorrectAmount = txOutValue == expectedAmount

        expectedAmount :: Value
        expectedAmount = valueLockedBy (txOutAddress txOut) txOut

    in deadlinePassed && outputToRecipient && outputHasCorrectAmount

-- Define the schema
data MyRedeemer = MyRedeemer
    deriving Show

instance ToJSON MyRedeemer where
    toJSON = genericToJSON defaultOptions

instance FromJSON MyRedeemer where
    parseJSON = genericParseJSON defaultOptions

type Schema = Endpoint "transfer" (Wallet, Value)

-- Define the contract endpoint
transfer :: Contract () Schema Text ()
transfer = do
    (receiver, amount) <- endpoint @"transfer"
    tenYearTransfer receiver amount

-- Compile the contract
mkSchemaDefinitions ''Schema
mkKnownCurrencies []
$(mkTxOutTypeScript (Proxy @MyRedeemer))
$(mkValidator 'validate)
$(deriveJSON defaultOptions ''MyRedeemer)

```

Hợp đồng thông minh này định nghĩa một chức năng được gọi tenYearTransferlà lấy địa chỉ ví ( receiver) và số lượng tiền tệ ( amount) làm đối số. Nó kiểm tra thời gian hiện tại để xem liệu đã 10 năm hay lâu hơn kể từ khi hợp đồng được tạo hay chưa và nếu vậy, sẽ tạo một giao dịch gửi số tiền được chỉ định đến địa chỉ ví được chỉ định.

Hợp đồng thông minh cũng xác định chức năng xác thực để kiểm tra xem giao dịch được thực hiện có sau thời hạn không và đầu ra có được gửi đến địa chỉ đã chỉ định với số tiền chính xác hay không. Hàm transferxác định một điểm cuối có thể được gọi để bắt đầu chuyển giao.

Tuyệt vời! Dưới đây là một số thông tin thêm về hợp đồng thông minh:

Hàm currentTimetrả về thời gian hiện tại trên chuỗi khối Cardano, được biểu thị dưới dạng POSIXTimegiá trị `POSIXTime.
Hàm slotToPOSIXTimechuyển đổi một giá trị Slotgiá trị POSIXTime. Trong trường hợp này, POSIXTimegiá trị
Hàm mustPayToPubKeytạo ra một
submitTxConstraintsHàm `submitTx
Hàm ` typedValidatortyped
chức getContinuingOutputsnăng
Hàm containskiểm tra POSIXTimeRangegiá trị có chứa một POSIXTimegiá trị ` đã cho.
txOutAddressGiá trị hàm `txOut TxOut.
Hàm paymentPubKeyHashtrả về ScriptContextgiá trị.
Hàm `valueLockedBy valueLockedBytrả về
Loại Endpointloại mất và như Schema_"transfer"WalletValue
loại chức mkSchemaDefinitionsnăngSchema
Hàm `mkTx mkTxOutTypeScriptlà MyRedeemerloại
mkValidatorChức năng `mkValidator
Hàm `deriveJSON deriveJSONlà MyRedeemerloại


Mở
Nhấp vào "Tập lệnh"
Sao chép và
Nhấp vào "Biên dịch
Nhấp vào "Trình mô phỏng"
Nhấp vào "Ví"
Nhấp vào "Thêm ví"
Nhập
Lựa chọn
Nhấp vào "Thêm tiền"
Đi vào
Đóng
Nhấp chuột
Nhấp chuột
Nhập ví
Nhấp chuột
Nếu như
Và




haithang311277@gmail.com
Tiếp tục
chức năng valueLockedBy trong trình xác thực để


