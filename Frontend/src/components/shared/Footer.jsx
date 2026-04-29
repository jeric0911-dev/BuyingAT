import {
  getFooterData,
  getPages,
  getSocial,
  getTopCategories,
} from "@/actions/others";
import FooterClient from "./FooterClient";

const Footer = async () => {
  const [{ data }, { data: socials }, { data: pages }, { data: categories }] =
    await Promise.all([
      getFooterData(),
      getSocial(),
      getPages(),
      getTopCategories(),
    ]);

  return (
    <FooterClient
      data={data}
      categories={categories}
      pages={pages}
      socials={socials}
    />
  );
};

export default Footer;
