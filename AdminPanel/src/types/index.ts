export * from "./global";
export * from "./types.rolePermission";

type TCore = {
  id: number;
  created_at: string;
  updated_at: string;
};

export type TCard = TCore & {
  card_title: string;
  description: string;
  price: number;
  grade: string;
  sport_type: string;
  weight: number;
  images: string[];
  request_status: 'pending' | 'approved' | 'rejected';
  seller_inventory: {
    id: number;
    card_title: string;
    description: string;
    price: number;
    grade: string;
    sport_type: string;
    weight: number;
    images: string[];
    user: {
      id: number;
      name: string;
      email: string;
    };
  };
};

export type TCategory = TCore & {
  category_name: string;
  slug: string;
  icon: string;
  banner: string;
  status: 0 | 1;
  sub_categories: TSubCategory[];
};

export type TSubCategory = TCore & {
  sub_category_name: string;
  category_id: number;
  category: TCategory;
} & Pick<TCategory, "slug" | "icon" | "banner" | "status">;

export type TChildCategory = TCore & {
  child_category_name: string;
  sub_category_id: number;
} & Pick<TCategory, "slug" | "icon" | "banner" | "status">;

export type TBlogCategory = TCore & {
  name: string;
};

export type TBlog = TCore & {
  blog_title: string;
  blog_content: string;
  blog_category_id: number;
  keyword: string;
  meta_tag: string;
  meta_description: string;
  slug: string;
  blog_thumb_img: string;
  cover_img: string;
};

export type TPage = TCore & {
  id: number;
  title: string;
  content: string;
  slug: string;
};

export type TBrand = TCore & {
  brand_name: string;
  category_id: number;
  icon: string;
  banner: string;
  slug: string;
  status: string;
};

export type TCountry = TCore & {
  country_name: string;
  status: 0 | 1;
};

export type TCityState = TCore & {
  country_id: number;
  status: 0 | 1;
  lat: number;
  long: number;
  city_name: string;
  state_name: string;
  country: TCountry;
};

export type TSlider = TCore & {
  img: string;
  link: string;
};

export type TAD = {
  id: number;
  img_1: string;
  link_1: string;
  img_2: string;
  link_2: string;
  img_3: string;
  link_3: string;
  img_4: string;
  link_4: string;
  img_5: string;
  link_5: string;
  img_6: string;
  link_6: string;
  img_7: string;
  link_7: string;
  img_8: string;
  link_8: string;
};

export type TSocial = TCore & {
  icon: string;
  link: string;
};

export type TFooter = {
  id: number;
  footer_logo: string;
  number: string;
  address: string;
  mail: string;
  copyright: string;
  google_play: string;
  app_store: string;
};

export type THeroSection = TCore & {
  logo: string;
  hero_title: string;
  hero_description: string;
  banner: string;
};

export type TShop = TCore & {
  user_id: number;
  name: string;
  slug: string;
  description: string;
  banner: string;
  status: "active" | "pending" | "rejected" | "disabled";
};

export type TFaq = TCore & {
  qua: string;
  ans: string;
};

export type TProduct = TCore & {
  product_title: string;
  price: string;
  discounted_price: string;
  product_description: string;
  stock: string;
  sku: string;
  status: "Pending" | "Active" | "Rejected" | "Unpublished" | "Disabled";
  is_featured: 0 | 1;
  get_gallery_images: {
    img: string;
  }[];
  get_category: {
    category_name: string;
  };
  get_sub_category: {
    sub_category_name: string;
  };
  get_brand: {
    brand_name: string;
  };
  colors: {
    color: string;
    color_name: string;
  }[];
  sizes: {
    size: string;
  }[];
  additional_info: {
    additional_info: string;
    specification: string;
  };
  variants: {
    variant_name: string;
    price: string;
    discounted_price: string;
  }[];
  get_product_user: {
    id: number;
    name: string;
    profile_img: string;
  };
};

export type TPackageCategory = TCore & {
  title: string;
  duration: number;
  status: 0 | 1;
};

export type TPackage = TCore & {
  title: string;
  price: number;
  duration: number;
  product_count: number;
  advert_count: number;
  package_category_id: number;
  package_category: TPackageCategory;
  package_advantage: { title: string }[];
};

export type TGateway = TCore & {
  id: number;
  gateway_name: string;
  alias: string;
  gateway_parameters: string;
  supported_currencies: string;
  status: number;
};

export type TMailConfig = TCore & {
  mailer: string;
  host: string;
  port: string;
  username: string;
  password: string;
  encryption: string;
  mail_from_address: string;
  mail_from_name: string;
};

export type TPusherConfig = TCore & {
  pusher_app_id: string;
  pusher_app_key: string;
  pusher_app_secret: string;
  pusher_host: string;
  pusher_port: string;
  pusher_scheme: string;
  pusher_app_cluster: string;
};

export type TGoogleCredential = TCore & {
  google_client_id: string;
  google_client_secret: string;
  google_redirect_uri: string;
};

export type TSupportTicket = TCore & {
  subject: string;
  priority: "low" | "medium" | "high";
  message: string;
  status: 0 | 1;
  ticket_id: string;
  messages?: TMessage[];
  user: { profile_img: string; name: string };
};

export type TMessage = TCore & {
  ticket_id: number;
  user_id: number;
  message: string;
  attachments?: any[];
  support_ticket: { status: 0 | 1; ticket_id: string };
  user: { profile_img: string; name: string };
};

export type TWebSettings = TCore & {
  web_app_logo: string;
  fav_icon: string;
  login_page_title: string;
  header_title: string;
  pixel_id: string;
  google_analytics_id: string;
  meta_title: string;
  meta_description: string;
  app_base_url: string;
  frontend_url: string;
  back_end_base_url: string;
  front_end_base_url: string;
};

export type TReport = TCore & {
  car_id: number;
  title: string;
  description: string;
  user_id: number;
  user: TUser;
  product: TProduct;
};

export type TUser = TCore & {
  name: string;
  email: string;
  phone: string;
  user_type: "regular" | "vendor";
  profile_img: string;
  status: 0 | 1;
  products?: TProduct[];
  shop?: TShop;
  user_package?: { package_name: string };
  blacklist?: Array<{
    type: string;
    content: string;
    context: string;
    timestamp: string;
    ip: string;
    user_agent: string;
  }>;
  violation_count?: number;
  last_violation_at?: string;
};

export type TClientQuery = {
  id: number;
  email: string;
  name: string;
  message: string;
};

export type TMeta = {
  active_cards: number;
  pending_cards: number;
  rejected_cards: number;
  active_users: number;
  inactive_users: number;
  active_tickets: number;
  client_queries: number;
  successful_deposits: number;
  admins: number;
  categories: number;
  free_package_users: number;
  standard_package_users: number;
  premium_package_users: number;
};

export type TTransaction = TCore & {
  user_id: number;
  transaction_id: string;
  initiated: string;
  payment_method: string;
  conversion: string;
  credits: null;
  amount: string;
  currency: string;
  status: string;
  user: TUser;
};

export type TCurrency = TCore & {
  currency_code: string;
  currency_symbol: string;
  value: string;
  status: 0 | 1;
};
