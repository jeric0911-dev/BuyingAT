<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Shop Request Rejected</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
        .container { background-color: white; padding: 30px; border-radius: 10px; max-width: 600px; margin: 0 auto; }
        .status { font-size: 24px; font-weight: bold; color: #e74c3c; margin-top: 20px; }
        .footer { margin-top: 30px; font-size: 12px; color: #888; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Shop Creation Request Rejected</h2>
        <p>Hello {{ $user_name }},</p>
        <p>We regret to inform you that your shop creation request has been <strong>rejected</strong>.</p>
        <div class="status">
            Status: Rejected
        </div>
        {{-- <p>Reason: {{ $rejection_reason }}</p> --}}
        <p>If you believe this decision was made in error or need clarification, please contact our support team.</p>
        <div class="footer">
            &copy; {{ date('Y') }} Dbug Station Limited. All rights reserved.
        </div>
    </div>
</body>
</html>
