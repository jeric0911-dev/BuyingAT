import { getUser } from "@/actions/auth";
import Container from "@/components/shared/Container";
import SideNav from "@/components/shared/SideNav";

export const dynamic = "force-dynamic";

const layout = async ({ children }) => {
  const { data: user } = await getUser();

  return (
    <Container>
      <div className="grid grid-cols-1 lg:grid-cols-[250px_1fr] gap-16 mt-10">
        <SideNav user={user} />
        {children}
      </div>
    </Container>
  );
};

export default layout;
