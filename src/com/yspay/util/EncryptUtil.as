package com.yspay.util
{
    import com.hurlant.crypto.Crypto;
    import com.hurlant.crypto.symmetric.ICipher;
    import com.hurlant.crypto.symmetric.IPad;
    import com.hurlant.crypto.symmetric.NullPad;
    import com.hurlant.util.Hex;

    import flash.utils.ByteArray;

    public class EncryptUtil
    {
        public function EncryptUtil()
        {
        }
        public static const txtKey:String = "1234567890123456";

        /*
           txtKey 密钥utf-8编码 txtPlain 要加密的文字 utf-8编码
           返回密文
         **/
        public static function encryptHandler(txtPlain:String):String
        {

            var keyData:ByteArray = Hex.toArray(Hex.fromString(EncryptUtil.txtKey));
            var plainData:ByteArray = new ByteArray;
            plainData.writeMultiByte(txtPlain, 'cn-gb');
            var len:int = plainData.length % 8;
            if (len != 0)
            {
                for (var i:int = 0; i < 8 - len; ++i)
                {
                    plainData.writeByte(0);
                }
            }
            for (var pd_idx:int = 0; pd_idx < plainData.length; ++pd_idx)
            {
                trace(plainData[pd_idx].toString(16));
            }
            var name:String = "des3-ecb";
            var pad:IPad = new NullPad;
            var mode:ICipher = Crypto.getCipher(name, keyData, pad);
            pad.setBlockSize(mode.getBlockSize());
            mode.encrypt(plainData);
            var result:String = Hex.fromArray(plainData);
            return result;

        }

        /*

         **/
        public static function decryptHandler(txtCipher:String):String
        {
            var keyData:ByteArray = Hex.toArray(Hex.fromString(EncryptUtil.txtKey));
            var cipherData:ByteArray = Hex.toArray(txtCipher);
            var name:String = "des3-ecb";
            var pad:IPad = new NullPad;
            var mode:ICipher = Crypto.getCipher(name, keyData, pad);
            pad.setBlockSize(mode.getBlockSize());
            mode.decrypt(cipherData);
            cipherData.position = 0;
            var result:String = cipherData.readMultiByte(cipherData.length, 'cn-gb');
            return result;
        }
    }
}