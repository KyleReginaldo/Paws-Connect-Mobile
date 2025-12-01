-- Create table for account deletion OTPs
CREATE TABLE account_deletion_otps (
  id SERIAL PRIMARY KEY,
  email TEXT NOT NULL,
  otp TEXT NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Add index for performance
  INDEX idx_account_deletion_otps_email_otp (email, otp),
  INDEX idx_account_deletion_otps_expires_at (expires_at),
  
  -- Add constraint to ensure OTP is 6 digits
  CONSTRAINT chk_otp_format CHECK (otp ~ '^\d{6}$')
);

-- Add RLS (Row Level Security) policies
ALTER TABLE account_deletion_otps ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access OTPs for their own email
CREATE POLICY "Users can only access their own OTPs" ON account_deletion_otps
  FOR ALL USING (auth.jwt() ->> 'email' = email);

-- Policy: Service role can manage all OTPs (for cleanup)
CREATE POLICY "Service role can manage all OTPs" ON account_deletion_otps
  FOR ALL TO service_role USING (true);

-- Create function to automatically clean up expired OTPs
CREATE OR REPLACE FUNCTION cleanup_expired_otps()
RETURNS void AS $$
BEGIN
  DELETE FROM account_deletion_otps 
  WHERE expires_at < NOW() OR used = true;
END;
$$ LANGUAGE plpgsql;

-- Schedule cleanup to run every hour (optional - requires pg_cron extension)
-- SELECT cron.schedule('cleanup-expired-otps', '0 * * * *', 'SELECT cleanup_expired_otps();');

-- Grant necessary permissions
GRANT ALL ON account_deletion_otps TO authenticated;
GRANT ALL ON account_deletion_otps TO service_role;