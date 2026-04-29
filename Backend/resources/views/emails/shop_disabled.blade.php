<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Shop Disabled Notification</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
        .container { background-color: #fff; padding: 30px; border-radius: 10px; max-width: 600px; margin: 0 auto; }
        .status { font-size: 22px; font-weight: bold; color: #e67e22; margin-top: 20px; }
        .footer { margin-top: 30px; font-size: 12px; color: #888; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Your Shop Has Been Disabled</h2>
        <p>Hello {{ $user_name }},</p>
        <p>We would like to inform you that your shop <strong>{{ $shop_name }}</strong> has been <strong>disabled</strong>.</p>
        <div class="status">
            Status: Disabled
        </div>
        @if(!empty($disabled_reason))
        <p>Reason: {{ $disabled_reason }}</p>
        @endif
        <p>If you believe this action was taken in error or need assistance, please contact our support team for clarification.</p>
        <div class="footer">
            &copy; {{ date('Y') }} Dbug Station Limited. All rights reserved.
        </div>
    </div>
</body>
</html>
