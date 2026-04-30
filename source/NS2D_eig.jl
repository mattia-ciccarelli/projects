

function eigAB(K::SparseMatrixCSC{Float64},M::SparseMatrixCSC{Float64},F0::Vector{Float64},nodes::Vector{Snode})

println("Computing eigenvalues")

neq=info.neq
neig=info.neig
uneq=info.uneq

mat"""
[$VR,$DR] = eigs(-$K,$M,$neig,0-2.5i);
$DR=diag($DR);
"""
for i=1:neig
 println(i," ",DR[i])
end

mat"""
[$VL,$DL] = eigs(-transpose($K),transpose($M),$neig,0-2.5i);
$DL=diag($DL);
"""
#println(DL)

# normalisation
for i = 1:neig
  cc = transpose(VL[:,i])*M*VR[:,i]
  # for j = 1:neq
  #   VR[j,i] /= sqrt(cc)
  #   VL[j,i] /= sqrt(cc)
  # end
  VR[:,i] /= norm(VR[:,i], Inf)
  VL[:,i] /= norm(VL[:,i], Inf)
  # outgmsheig(info.NN,nodes,real(VR[:,i]),"_eig"*string(i))  # prints displacements
end

VR_nu=zeros(Float64,neq)
#ps = MKLPardisoSolver()
#solve!(ps,VR_nu,K,F0)
VR_nu = K \ F0
# VR_nu /= norm(VR_nu, Inf)
# outgmsheig(info.NN,nodes,VR_nu,"_eig"*string(neig+1))  # prints displacements

return DR,VR,VL,VR_nu

end


function eigABiter(K::SparseMatrixCSC{Float64},M::SparseMatrixCSC{Float64},F0::Vector{Float64},nodes::Vector{Snode})

  println("Computing eigenvalues")

  neq=info.neq
  neig=info.neig
  uneq=info.uneq

  mat"""
  [$VR,$DR] = eigs(-$K,$M,$neig,'SM');
  $DR=diag($DR);
  """
  for i=1:neig
   println(i," ",DR[i])
  end

  mat"""
  [$VL,$DL] = eigs(-transpose($K),transpose($M),$neig,'SM');
  $DL=diag($DL);
  """
  #println(DL)

  # normalisation
  for i = 1:neig
    cc = transpose(VL[:,i])*M*VR[:,i]  # compl conj
    for j = 1:neq   # arbitrary: scales only VR  (seems to coincide with old approach)
      VR[j,i] /= sqrt(cc)
      VL[j,i] /= sqrt(cc)
    end
  #=   VR[:,i] /= norm(VR[:,i], Inf)
    VL[:,i] /= norm(VL[:,i], Inf) =#
    # outgmsheig(info.NN,nodes,real(VR[:,i]),"_eig"*string(i))  # prints displacements
  end

  VR_nu=zeros(Float64,neq)
  ps = MKLPardisoSolver()
  solve!(ps,VR_nu,K,F0)
  # outgmsheig(info.NN,nodes,VR_nu,"_eig"*string(neig+1))  # prints displacements

  return DR,VR,VL,VR_nu

  end

  function eigAB_Uchannel(K::SparseMatrixCSC{Float64}, M::SparseMatrixCSC{Float64}, F0::Vector{Float64}, nodes::Vector{Snode})

    println("Computing eigenvalues with multiple shifts")

    neq = info.neq
    neig = info.neig
    # uneq = info.uneq 

    shifts = [+2.5im +7.5im -2.5im -7.5im]
    
    DR_all = ComplexF64[]
    VR_all = Matrix{ComplexF64}(undef, neq, 0)
    VL_all = Matrix{ComplexF64}(undef, neq, 0)

    for actuals in shifts
        println("actual shift = ", actuals)

        mat"""
        [$VR_tmp,$DR_tmp] = eigs(-$K,$M,$neig,$actuals);
        $DR_tmp=diag($DR_tmp);
        
        [$VL_tmp,$DL_tmp] = eigs(-transpose($K),transpose($M),$neig,$actuals);
        $DL_tmp=diag($DL_tmp);
        """
        
        append!(DR_all, DR_tmp)
        VR_all = hcat(VR_all, VR_tmp) 
        VL_all = hcat(VL_all, VL_tmp)
    end

    println("Filtering")
    tol = 1e-5 
    indices = Int[]
    
    for i = 1:length(DR_all)
        double = false
        for j in indices
            if abs(DR_all[i] - DR_all[j]) < tol
                double = true
                break
            end
          end
        if !double
            push!(indices, i)
        end
    end

    # Extraction of unique eigenvalues/vector
    DR_unique = DR_all[indices]
    VR_unique = VR_all[:, indices]
    VL_unique = VL_all[:, indices]
    
    num_unique = length(DR_unique)
    
    #normalization
    for i = 1:num_unique
        #cc = transpose(VL_unique[:,i]) * M * VR_unique[:,i]
        
        VR_unique[:,i] /= norm(VR_unique[:,i], Inf)
        VL_unique[:,i] /= norm(VL_unique[:,i], Inf)
    end

    VR_nu = zeros(Float64, neq)
    VR_nu = K \ F0

    println("\nFinal eigenvalue spectrum:")
    for i = 1:num_unique
        println("Mode ", i, ": ", DR_unique[i])
    end

    return DR_unique, VR_unique, VL_unique, VR_nu

end
