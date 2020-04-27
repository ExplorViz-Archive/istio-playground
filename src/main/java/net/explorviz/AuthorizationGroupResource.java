package net.explorviz;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

@Path("/secretgroup")
public class AuthorizationGroupResource {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public String secret() {
        return "{\"theSecret\": \"This is a secret page for the secret:group\"}";
    }
}