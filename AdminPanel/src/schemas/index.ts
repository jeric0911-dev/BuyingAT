import { z } from "zod";

export const LoginValidation = z.object({
  email: z.string().email({ message: "Invalid email address" }),
  password: z.string().min(8, "Password must be at least 8 characters long"),
});

export const AddBlogCategoryValidation = z.object({
  name: z.string().min(1, { message: "Name is required" }),
});

export const AddSliderValidation = z.object({
  img: z
    .instanceof(File, { message: "Slider Image is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg",
        ].includes(file.type),
      { message: "Invalid file type" }
    ),
  link: z.string().url(),
});

export const UpdateSliderValidation = z.object({
  img: z
    .instanceof(File, { message: "Slider Image is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg",
        ].includes(file.type),
      { message: "Invalid file type" }
    )
    .optional(),
  link: z.string().url(),
});

export const AddCountryValidation = z.object({
  country_name: z.string().min(1, { message: "Name is required" }),
});

export const AddCityValidation = z.object({
  city_name: z.string().min(1, { message: "City name is required" }),
  country_id: z.number().min(1, { message: "Select a country" }),
});

export const AddStateValidation = z.object({
  state_name: z.string().min(1, { message: "City name is required" }),
  country_id: z.number().min(1, { message: "Select a country" }),
});

const AddCategoryCommon = z.object({
  icon: z
    .instanceof(File, { message: "Icon is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg+xml",
        ].includes(file.type),
      { message: "Invalid file type" }
    ),
  banner: z
    .instanceof(File, { message: "Banner Image is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg+xml",
        ].includes(file.type),
      { message: "Invalid file type" }
    ),
});
const UpdateCategoryCommon = z.object({
  icon: z
    .instanceof(File, { message: "Icon is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg",
        ].includes(file.type),
      { message: "Invalid file type" }
    )
    .optional(),
  banner: z
    .instanceof(File, { message: "Banner Image is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg",
        ].includes(file.type),
      { message: "Invalid file type" }
    )
    .optional(),
});
export const AddCategoryValidation = AddCategoryCommon.merge(
  z.object({
    category_name: z.string().min(1, { message: "Name is required" }),
  })
);
export const UpdateCategoryValidation = UpdateCategoryCommon.merge(
  z.object({
    category_name: z.string().min(1, { message: "Name is required" }),
  })
);
export const AddSubCategoryValidation = AddCategoryCommon.merge(
  z.object({
    sub_category_name: z.string().min(1, { message: "Name is required" }),
    category_id: z.number().min(1, { message: "select a category" }),
  })
);
export const UpdateSubCategoryValidation = UpdateCategoryCommon.merge(
  z.object({
    sub_category_name: z.string().min(1, { message: "Name is required" }),
    category_id: z.number().min(1, { message: "select a category" }),
  })
);
export const AddChildCategoryValidation = AddCategoryCommon.merge(
  z.object({
    child_category_name: z.string().min(1, { message: "Name is required" }),
    sub_category_id: z.number().min(1, { message: "select a sub category" }),
  })
);
export const UpdateChildCategoryValidation = UpdateCategoryCommon.merge(
  z.object({
    child_category_name: z.string().min(1, { message: "Name is required" }),
    sub_category_id: z.number().min(1, { message: "select a sub category" }),
  })
);

export const AddBlogValidation = z.object({
  blog_title: z.string().min(1, { message: "Title is required" }),
  keyword: z.string().min(1, { message: "Meta keyword is required" }),
  meta_description: z.string().min(1, { message: "Meta title is required" }),
  blog_category_id: z.number().min(1, { message: "Select a category" }),
  blog_thumb_img: z
    .instanceof(File, { message: "Thumb image is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg",
        ].includes(file.type),
      { message: "Invalid file type" }
    ),
  cover_img: z
    .instanceof(File, { message: "Cover image is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg",
        ].includes(file.type),
      { message: "Invalid file type" }
    ),
});
export const UpdateBlogValidation = z.object({
  blog_title: z.string().min(1, { message: "Title is required" }),
  keyword: z.string().min(1, { message: "Meta keyword is required" }),
  meta_description: z.string().min(1, { message: "Meta title is required" }),
  blog_category_id: z.number().min(1, { message: "Select a category" }),
  blog_thumb_img: z
    .instanceof(File, { message: "Thumb image is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg",
        ].includes(file.type),
      { message: "Invalid file type" }
    )
    .optional(),
  cover_img: z
    .instanceof(File, { message: "Cover image is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg",
        ].includes(file.type),
      { message: "Invalid file type" }
    )
    .optional(),
});

export const AddBrandValidation = AddCategoryCommon.merge(
  z.object({
    brand_name: z.string().min(1, { message: "Name is required" }),
  })
);
export const UpdateBrandValidation = UpdateCategoryCommon.merge(
  z.object({
    brand_name: z.string().min(1, { message: "Name is required" }),
  })
);

export const UpdateHeroValidation = z.object({
  hero_title: z.string().min(1, { message: "Title is required" }),
  hero_description: z.string().min(1, { message: "Description is required" }),
  banner: z
    .instanceof(File, { message: "Banner is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg+xml",
        ].includes(file.type),
      { message: "Invalid file type" }
    )
    .optional(),
});

export const UpdateFooterValidation = z.object({
  number: z.string().min(1, { message: "Number is required" }),
  address: z.string().min(1, { message: "Address is required" }),
  mail: z.string().email("Invalid email address"),
  copyright: z.string().min(1, { message: "Copyright is required" }),
  google_play: z.string().url("Invalid URL"),
  app_store: z.string().url("Invalid URL"),
  footer_logo: z
    .instanceof(File, { message: "Footer logo is required" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg+xml",
        ].includes(file.type),
      { message: "Invalid file type" }
    )
    .optional(),
});

export const AddPageValidation = z.object({
  title: z.string().min(1, { message: "Title is required" }),
});

export const AddAdminValidation = z.object({
  username: z.string().min(1, "Name is required"),
  email: z.string().email("Invalid email address"),
  password: z.string().min(8, "password must be at least 8 characters long"),
  admin_type_id: z.number().min(1, { message: "Select a role" }),
});

export const UpdateAdminValidation = z.object({
  username: z.string().min(1, { message: "Name is required" }),
  email: z.string().email("Invalid email address"),
  password: z
    .string()
    .optional()
    .refine((val) => !val || val.length >= 8, {
      message: "Password must be at least 8 characters long",
    }),
  admin_type_id: z.number().min(1, { message: "Select a role" }),
});

export const AddNotificationValidation = z.object({
  title: z.string().min(1, { message: "Title is required" }),
  body: z.string().min(1, { message: "Body is required" }),
  link: z.string().url(),
  // image: z.instanceof(File, { message: "Image is required" }),
});

export const AddFaqValidation = z.object({
  qua: z.string().min(1, { message: "Question is required" }),
  ans: z.string().min(1, { message: "Answer is required" }),
});

export const AddSocialValidation = z.object({
  link: z.string().url(),
  icon: z.instanceof(File, { message: "Icon is required" }),
});

export const UpdateSocialValidation = z.object({
  link: z.string().url(),
  icon: z.instanceof(File, { message: "Icon is required" }).optional(),
});

export const AddTwilioCredentialValidation = z.object({
  twilioAccountSid: z
    .string()
    .min(1, { message: "Twilio account Sid is required" }),
  twilioAuthToken: z
    .string()
    .min(1, { message: "Twilio auth token is required" }),
  twilioPhoneNumber: z
    .string()
    .min(1, { message: "Twilio phone number is required" }),
});

export const AddGoogleCredentialValidation = z.object({
  google_client_id: z.string().min(1, { message: "Client ID is required" }),
  google_client_secret: z
    .string()
    .min(1, { message: "Client secret is required" }),
  google_redirect_uri: z
    .string()
    .min(1, { message: "Redirect URL is required" }),
});

export const AddStripeCredentialValidation = z.object({
  stripeSecretKey: z
    .string()
    .min(1, { message: "Stripe secret key is required" }),
  stripePublicKey: z
    .string()
    .min(1, { message: "Stripe public key is required" }),
});

export const AddRazorpayCredentialValidation = z.object({
  razorpayKey: z.string().min(1, { message: "Razorpay key is required" }),
  razorpaySecret: z.string().min(1, { message: "Razorpay secret is required" }),
});

export const AppSettingsValidation = z.object({
  website: z.string().url(),
  whatsApp: z
    .string()
    .refine((value) => /^[+]{1}(?:[0-9-()/.]\s?){6,15}[0-9]{1}$/.test(value)),
  facebook: z.string().url(),
  x: z.string().url(),
  instagram: z.string().url(),
});

export const WebSettingsValidation = z.object({
  login_page_title: z
    .string()
    .min(1, { message: "Login page title is required" }),
  header_title: z.string().min(1, { message: "Header title is required" }),
  web_app_logo: z
    .instanceof(File, { message: "Invalid file provided for Web App Logo" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg+xml",
          "image/svg",
        ].includes(file.type),
      { message: "Invalid file type. Only images are allowed." }
    )
    .optional(),
  google_analytics_id: z.string().optional(),
  pixel_id: z.string().optional(),
  meta_title: z.string().min(1, { message: "Meta title is required" }),
  meta_description: z
    .string()
    .min(1, { message: "Meta description is required" }),
  app_base_url: z.string().url({ message: "Invalid URL format" }),
  frontend_url: z.string().url({ message: "Invalid URL format" }),
  back_end_base_url: z.string().url({ message: "Invalid URL format" }),
  front_end_base_url: z.string().url({ message: "Invalid URL format" }),
  fav_icon: z
    .instanceof(File, { message: "Invalid file provided for Fav Icon" })
    .refine(
      (file) =>
        [
          "image/jpg",
          "image/jpeg",
          "image/png",
          "image/webp",
          "image/avif",
          "image/svg+xml",
          "image/svg",
          "image/x-icon",
        ].includes(file.type),
      { message: "Invalid file type for favicon." }
    )
    .optional(),
});

export const AddPackageCategoryValidation = z.object({
  title: z.string().min(1, { message: "Title is required" }),
  duration: z.number().min(1, { message: "Duration is required" }),
  status: z.any(),
});

export const AddCurrencyValidation = z.object({
  currency_code: z.string().min(1, { message: "Currency code is required" }),
  currency_symbol: z
    .string()
    .min(1, { message: "Currency symbol is required" }),
  value: z.coerce
    .number({
      invalid_type_error: "Value is required",
    })
    .min(0.01, { message: "Value must be greater than 0" }),
});
