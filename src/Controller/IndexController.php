<?php
namespace App\Controller;

use DateTime;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\Routing\Annotation\Route;

class IndexController extends Controller
{
    /**
     * @Route("/", name="index_locale")
     */
    public function locale()
    {
        $data = [
            'version'  => \Symfony\Component\HttpKernel\Kernel::VERSION,
            'datetime' => (new DateTime())->format('c'),
            'hostname' => gethostname(),
        ];

        return $this->render('welcome.html.twig', $data);
    }
}